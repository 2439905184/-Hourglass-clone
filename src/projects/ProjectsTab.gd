extends HBoxContainer


enum SortMode {
	LAST_MODIFIED,
	NAME,
	VERSION,
}

const PROJECT_LIST_ITEM = preload("res://src/projects/ProjectListItem.tscn")

var search_query: String setget set_search_query, get_search_query

var _selected := []

onready var open: Button = $Margin/VBox/Open
onready var show_files: Button = $Margin/VBox/ShowFiles
onready var run: Button = $Margin/VBox/Run
onready var remove: Button = $Margin/VBox/Remove
onready var edit: Button = $Margin/VBox/Edit
onready var sort_mode: OptionButton = $VBox/Margin/HBox/SortMode

onready var import_file: FileDialog = $Dialogs/ImportFile

onready var project_list: VBoxContainer = $VBox/Scroll/Margin/ProjectList
onready var new_project := $Dialogs/NewProject
onready var import_dialog := $Dialogs/ImportDialog
onready var edit_project_dialog := $Dialogs/EditProjectDialog


func _ready() -> void:
	sort_mode.select(Config.sort_mode)
	import_file.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)

	for project_id in Projects.get_projects():
		_add_project(project_id)
	_sort_and_filter()

	Projects.connect("project_added", self, "_on_project_added")
	Projects.connect("project_changed", self, "_on_project_changed")
	Projects.connect("project_removed", self, "_on_project_removed")


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

	var search: String = search_query

	for i in range(projects.size()):
		project_list.move_child(projects[i], i)
		if not search.empty():
			var name : String = projects[i].project_name
			projects[i].visible = (name.findn(search) >= 0)
		else:
			projects[i].visible = true


func _project_sorter(a, b) -> bool:
	var a_favorite := Projects.get_project_favorite(a.project_id)
	var b_favorite := Projects.get_project_favorite(b.project_id)
	if a_favorite != b_favorite:
		return a_favorite

	match Config.sort_mode:
		SortMode.NAME:
			var name_a := Projects.get_project_name(a.project_id)
			var name_b := Projects.get_project_name(b.project_id)
			return name_a < name_b
		SortMode.LAST_MODIFIED:
			var mod_a := Projects.get_project_last_opened(a.project_id)
			var mod_b := Projects.get_project_last_opened(b.project_id)
			return mod_a >= mod_b
		SortMode.VERSION:
			var version_a := Projects.get_project_version(a.project_id)
			var version_b := Projects.get_project_version(b.project_id)
			return Versions.sort_versions(version_a, version_b)
		_:
			return false


func _on_project_added(project_id: String) -> void:
	_add_project(project_id)
	_sort_and_filter()


func _on_project_changed(_project_id: String) -> void:
	_sort_and_filter()


func _on_project_removed(project_id: String) -> void:
	for project in project_list.get_children():
		if project.project_id == project_id:
			project.queue_free()
			if project in _selected:
				_selected.erase(project)


func _on_New_pressed() -> void:
	new_project.popup_centered()


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


func _on_Remove_pressed() -> void:
	for project in _selected.duplicate():
		project.remove()


func _on_Edit_pressed() -> void:
	if _selected.size() == 1:
		edit_project_dialog.show_dialog(_selected[0].project_id)


func _on_Import_pressed() -> void:
	import_file.popup_centered()


func _on_ImportFile_file_selected(path: String) -> void:
	import_dialog.path = path
	import_dialog.show_dialog()


func _on_sort_selected(id: int) -> void:
	Config.sort_mode = id
	_sort_and_filter()
