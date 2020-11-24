extends BaseDialog


var path: String setget set_path

onready var version_dropdown: VersionDropdown = $VBox/HBox/VersionDropdown


func _ready() -> void:
	self.content_size = Vector2(300, 125)
	self.ok_text = tr("Import")


func show_dialog() -> void:
	version_dropdown.refresh()
	.show_dialog()


func set_path(new_path: String) -> void:
	path = new_path
	var cfg = ConfigFile.new()
	if cfg.load(path) != OK:
		ErrorDialog.show_error("Could Not Import Project", "The project.godot file could not be loaded.")
		return

	var name = cfg.get_value("application", "config/name")
	self.title = tr("Import {name}").format({"name":name})


func _on_confirmed() -> void:
	Projects.create_project(path.get_base_dir(), version_dropdown.get_selected_version())
