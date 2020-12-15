extends Control


const PROJECT_LIST_ITEM = preload("res://src/projects/ProjectListItem.tscn")

var search_query: String setget set_search_query, get_search_query

var _selected := []

onready var menu := $DropdownMenu
onready var open: Button = $DropdownMenu/VBox/Open
onready var show_files: Button = $DropdownMenu/VBox/ShowFiles
onready var run: Button = $DropdownMenu/VBox/Run
onready var remove: Button = $DropdownMenu/VBox/Remove
onready var edit: Button = $DropdownMenu/VBox/Edit

onready var import_file: FileDialog = $Dialogs/ImportFile

onready var scroll: ScrollContainer = $VBox/Scroll
onready var project_list: VBoxContainer = $VBox/Scroll/ProjectList
onready var new_project := $Dialogs/NewProject
onready var import_dialog := $Dialogs/ImportDialog
onready var edit_project_dialog := $Dialogs/EditProjectDialog
onready var confirm_remove: BaseDialog = $Dialogs/ConfirmRemove
onready var confirm_remove_label: Label = $Dialogs/ConfirmRemove.get_node("Label")
onready var column_header := $VBox/ColumnHeader
onready var welcome := $VBox/Welcome
onready var welcome_heading := $VBox/Welcome/VBox/Heading
onready var welcome_instructions := $VBox/Welcome/VBox/Instructions


func _ready() -> void:
	import_file.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)

	for project_id in Projects.get_projects():
		_add_project(project_id)
	_sort_and_filter()

	Projects.connect("project_added", self, "_on_project_added")
	Projects.connect("project_changed", self, "_on_project_changed")
	Projects.connect("project_removed", self, "_on_project_removed")
	Versions.connect("versions_updated", self, "_set_welcome_text")

	scroll.get_v_scrollbar().connect("visibility_changed", self, "_on_scrollbar_visibility_changed")

	Config.connect("projects_sort_changed", self, "_on_projects_sort_changed")


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_RIGHT:
			show_menu()


func select_project(project: ProjectListItem, shift=false) -> void:
	if not shift:
		for item in _selected:
			item.set_selected(false)
		_selected.clear()

	if shift and project.get_selected():
		_selected.remove(_selected.find(project))
		project.set_selected(false)
	else:
		_selected.append(project)
		project.set_selected(true)

	var none := _selected.size() <= 0
	open.disabled = none
	show_files.disabled = none
	run.disabled = none
	remove.disabled = none

	edit.disabled = _selected.size() != 1


func create_new_project() -> void:
	new_project.show_dialog()


func import_project() -> void:
	import_file.popup_centered()


func show_menu() -> void:
	if _selected.size() > 0:
		menu.rect_position = get_viewport().get_mouse_position()
		menu.popup()


func set_search_query(new_search_query: String) -> void:
	search_query = new_search_query
	_sort_and_filter()

func get_search_query() -> String:
	return search_query


func _add_project(project_id: String) -> void:
	var project := PROJECT_LIST_ITEM.instance()
	project.project_id = project_id
	project_list.add_child(project)


func _sort_and_filter() -> void:
	var projects := project_list.get_children()
	projects.sort_custom(self, "_project_sorter")

	for i in range(projects.size()):
		project_list.move_child(projects[i], i)
		if not search_query.empty():
			var name : String = projects[i].project_name
			projects[i].visible = (name.findn(search_query) >= 0)
		else:
			projects[i].visible = true

	if projects.size() == 0:
		welcome.show()
		scroll.hide()
		_set_welcome_text()
	else:
		welcome.hide()
		scroll.show()


func _set_welcome_text() -> void:
	if not Versions.any_installed():
		welcome_heading.text = tr("Godot Engine is not yet installed")
		welcome_instructions.text = tr("Go to the Versions tab to install Godot.")
	else:
		welcome_heading.text = tr("No projects yet")
		welcome_instructions.text = tr("Create a new project, or import your existing ones")


func _project_sorter(a, b) -> bool:
	var a_favorite := Projects.get_project_favorite(a.project_id)
	var b_favorite := Projects.get_project_favorite(b.project_id)
	if a_favorite != b_favorite:
		return a_favorite

	var result := _project_sorter_real(a, b)
	if Config.projects_sort_ascending:
		return !result
	else:
		return result


func _project_sorter_names(a, b) -> bool:
	var name_a := Projects.get_project_name(a.project_id)
	var name_b := Projects.get_project_name(b.project_id)
	return name_a.nocasecmp_to(name_b) == -1


func _project_sorter_real(a, b) -> bool:
	match Config.projects_sort:
		Config.SortMode.NAME:
			return _project_sorter_names(a, b)

		Config.SortMode.LAST_OPENED:
			var mod_a := Projects.get_project_last_opened(a.project_id)
			var mod_b := Projects.get_project_last_opened(b.project_id)

			if mod_a == mod_b:
				return _project_sorter_names(a, b)
			else:
				return mod_a >= mod_b

		Config.SortMode.VERSION:
			var version_a := Projects.get_project_version(a.project_id)
			var version_b := Projects.get_project_version(b.project_id)

			if version_a == version_b:
				return _project_sorter_names(a, b)
			else:
				return Versions.sort_versions(version_a, version_b)

		_:
			return _project_sorter_names(a, b)


func _on_project_added(project_id: String) -> void:
	_add_project(project_id)
	_sort_and_filter()


func _on_project_changed(_project_id: String) -> void:
	_sort_and_filter()


func _on_project_removed(project_id: String) -> void:
	for project in project_list.get_children():
		if project.project_id == project_id:
			project_list.remove_child(project)
			project.queue_free()
			if project in _selected:
				_selected.erase(project)

	if project_list.get_children().size() == 0:
		# that was the last project
		# use _sort_and_filter to show the welcome screen again
		_sort_and_filter()


func _on_Open_pressed() -> void:
	var success := 0
	for project in _selected:
		success |= project.open()

	if success == OK:
		find_parent("MainWindow").quit()


func _on_Run_pressed() -> void:
	var success := 0
	for project in _selected:
		success |= project.run()

	if success == OK:
		find_parent("MainWindow").quit()


func _on_ShowFiles_pressed() -> void:
	for project in _selected:
		project.show_files()
	menu.hide()


func _on_Remove_pressed() -> void:
	if _selected.size() == 1:
		confirm_remove.title = tr("Remove project?")
		confirm_remove_label.text = tr("Are you sure you want to remove %s from the list? No files will be deleted.") % _selected[0].project_name
	else:
		confirm_remove.title = tr("Remove projects?")
		confirm_remove_label.text = tr("Are you sure you want to remove %d projects from the list? No files will be deleted.") % _selected.size()

	confirm_remove.content_size = Vector2(250, 150)
	confirm_remove.show_dialog()
	menu.hide()


func _on_ConfirmRemove_confirmed() -> void:
	for project in _selected.duplicate():
		project.remove()


func _on_Edit_pressed() -> void:
	if _selected.size() == 1:
		edit_project_dialog.show_project_dialog(_selected[0].project_id)
	menu.hide()


func _on_ImportFile_file_selected(path: String) -> void:
	import_dialog.path = path
	import_dialog.show_dialog()


func _on_projects_sort_changed() -> void:
	_sort_and_filter()


func _on_scrollbar_visibility_changed() -> void:
	print("***** VISIBILITY ", scroll.get_v_scrollbar().visible)
	var stylebox := scroll.get_stylebox("bg")
	if scroll.get_v_scrollbar().visible:
		stylebox.content_margin_right = 15
	else:
		print("***** SIZE ", scroll.get_v_scrollbar().rect_size.x)
		stylebox.content_margin_right = scroll.get_v_scrollbar().rect_size.x + 15
