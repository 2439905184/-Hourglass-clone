extends HBoxContainer

const PROJECT_LIST_ITEM = preload("res://src/ProjectListItem.tscn")

enum SortMode {
	LAST_MODIFIED,
	NAME,
}

var _selected := []


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
	$Margin/VBox/Open.disabled = none
	$Margin/VBox/ShowFiles.disabled = none
	$Margin/VBox/Run.disabled = none
	$Margin/VBox/Remove.disabled = none

	$Margin/VBox/Edit.disabled = _selected.size() != 1


func _ready() -> void:
	$VBox/Margin/HBox/SortMode.select(Config.sort_mode)

	for project_id in Projects.get_projects():
		_add_project(project_id)
	_sort_and_filter()

	Projects.connect("project_added", self, "_on_project_added")
	Projects.connect("project_changed", self, "_on_project_changed")
	Projects.connect("project_removed", self, "_on_project_removed")

func _add_project(project_id: String) -> void:
	var project = PROJECT_LIST_ITEM.instance()
	project.project_id = project_id
	$VBox/Scroll/Margin/VBox.add_child(project)

func _sort_and_filter() -> void:
	var projects = $VBox/Scroll/Margin/VBox.get_children()
	projects.sort_custom(self, "_project_sorter")

	var search : String = $VBox/Margin/HBox/Search.text

	for i in range(projects.size()):
		$VBox/Scroll/Margin/VBox.move_child(projects[i], i)
		if not search.empty():
			var name : String = projects[i].project_name
			projects[i].visible = (name.findn(search) >= 0)
		else:
			projects[i].visible = true

func _project_sorter(a, b) -> bool:
	match Config.sort_mode:
		SortMode.NAME:
			var name_a := Projects.get_project_name(a.project_id)
			var name_b := Projects.get_project_name(b.project_id)
			return name_a < name_b
		SortMode.LAST_MODIFIED:
			var mod_a := Projects.get_project_last_opened(a.project_id)
			var mod_b := Projects.get_project_last_opened(b.project_id)
			return mod_a >= mod_b
		_:
			return false

func _on_project_added(project_id: String) -> void:
	_add_project(project_id)
	_sort_and_filter()

func _on_project_changed(project_id: String) -> void:
	_sort_and_filter()

func _on_project_removed(project_id: String) -> void:
	for project in $VBox/Scroll/Margin/VBox.get_children():
		if project.project_id == project_id:
			project.queue_free()
			if project in _selected:
				_selected.erase(project)

func _on_New_pressed() -> void:
	$Dialogs/NewProject.popup_centered()

func _on_Open_pressed() -> void:
	var success := 0
	for project in _selected:
		success |= project.open()

	if success == OK: get_tree().quit()

func _on_Run_pressed() -> void:
	var success := 0
	for project in _selected:
		success |= project.run()

	if success == OK: get_tree().quit()

func _on_ShowFiles_pressed() -> void:
	for project in _selected:
		project.show_files()

func _on_Remove_pressed() -> void:
	for project in _selected:
		project.remove()

func _on_Edit_pressed() -> void:
	if _selected.size() == 1:
		$Dialogs/EditProjectDialog.show_dialog(_selected[0].project_id)

func _on_Import_pressed() -> void:
	$Dialogs/ImportFile.popup_centered()

func _on_ImportFile_file_selected(path: String) -> void:
	$Dialogs/ImportDialog.path = path
	$Dialogs/ImportDialog.show_dialog()

func _on_sort_selected(id: int) -> void:
	Config.sort_mode = id
	_sort_and_filter()

func _on_Search_text_changed(new_text: String) -> void:
	_sort_and_filter()

