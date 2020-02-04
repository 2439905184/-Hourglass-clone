extends ConfirmationDialog


var path : String setget set_path

onready var version_dropdown: VersionDropdown = $VBox/HBox/VersionDropdown


func _ready() -> void:
	get_ok().text = tr("Import")


func show_dialog() -> void:
	$VBox/HBox/VersionDropdown.refresh()
	rect_size = Vector2(0, 0)
	popup_centered_minsize()

func set_path(new_path: String) -> void:
	path = new_path
	var cfg = ConfigFile.new()
	if cfg.load(path) != OK:
		ErrorDialog.show_error("Could Not Import Project", "The project.godot file could not be loaded.")
		return

	var name = cfg.get_value("application", "config/name")
	window_title = tr("Import {name}").format({"name":name})


func _on_confirmed() -> void:
	var project_id := Projects.create_project(path.get_base_dir(), version_dropdown.get_selected_version())
