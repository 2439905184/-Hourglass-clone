extends BaseDialog


var _project_id: String

onready var version_dropdown: VersionDropdown = $HBox/VersionDropdown


func show_project_dialog(project_id: String) -> void:
	_project_id = project_id
	var version := Projects.get_project_version(project_id)
	version_dropdown.refresh()
	version_dropdown.selected_version = version

	self.title = tr("Edit {name}").format({"name": Projects.get_project_name(project_id)})

	show_dialog()


func _on_confirmed() -> void:
	Projects.set_project_version(_project_id, version_dropdown.selected_version)
