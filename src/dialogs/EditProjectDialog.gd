extends ConfirmationDialog

var _project_id : String

func show_dialog(project_id: String) -> void:
	_project_id = project_id
	var version := Projects.get_project_version(project_id)
	$HBox/VersionDropdown.refresh()
	$HBox/VersionDropdown.selected_version = version

	window_title = tr("Edit {name}").format({"name": Projects.get_project_name(project_id)})

	rect_size = Vector2(0, 0)
	popup_centered_minsize()

func _on_confirmed() -> void:
	Projects.set_project_version(_project_id, $HBox/VersionDropdown.selected_version)
