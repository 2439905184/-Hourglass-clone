extends ConfirmationDialog

func show_dialog() -> void:
	$VBox/HBox3/VersionDropdown.refresh()

func _ready() -> void:
	_set_name(tr("New Project"))
	_set_location(Config.get_project_location())

func _on_Browse_pressed() -> void:
	if _location_exists():
		$Browse.current_dir = _get_location()
	else:
		$Browse.current_dir = _get_location().get_base_dir()
	$Browse.popup_centered_minsize()

func _get_name() -> String:
	return $VBox/HBox/Name.text
func _set_name(name: String) -> void:
	$VBox/HBox/Name.text = name
	_validate()
func _get_location() -> String:
	return $VBox/HBox2/Location.text
func _set_location(location: String) -> void:
	$VBox/HBox2/Location.text = location
	_validate()
func _get_version() -> String:
	return $VBox/HBox3/VersionDropdown.get_selected_version()

func _on_Browse_dir_selected(dir: String) -> void:
	_set_location(dir)

func _on_CreateFolder_pressed() -> void:
	var folder = _get_name().to_lower().replace(" ", "-")
	var current = _get_location()
	_set_location(current.plus_file(folder))

func _on_Name_text_entered(_1: String) -> void:
	_on_CreateFolder_pressed()

func _location_exists() -> bool:
	var dir = Directory.new()
	return dir.dir_exists(_get_location())

func _validate() -> bool:
	var valid := true

	if _get_name().strip_edges().empty():
		valid = false

	if _location_exists():
		$VBox/AlreadyExists.modulate.a = 1
		valid = false
	else:
		$VBox/AlreadyExists.modulate.a = 0

	get_ok().disabled = not valid
	return valid

func _on_Location_text_changed(_1: String) -> void:
	_validate()
func _on_Name_text_changed(_1: String) -> void:
	_validate()


func _on_version_selected(id: int) -> void:
	var version = $VBox/HBox3/VersionDropdown.get_selected_version()
	$VBox/HBox3/GLVersion.visible = (Versions.get_config_version(version) >= 4)

func _on_confirmed() -> void:
	if _validate():
		var creator := ProjectCreator.new()
		var ret := creator.create_project(
			_get_location(),
			_get_name(),
			_get_version(),
			$VBox/HBox3/GLVersion/GL2.pressed
		)

		if ret != OK:
			ErrorDialog.show_error("Failed to Create Project", "An error occurred while creating the project. Check the console for more information.")
			return

		ret = Projects.open_project(creator.project_id)
		if ret == OK:
			get_tree().quit()

func _on_About_pressed() -> void:
	$AboutGLES.get_cancel().text = tr("Close")
	$AboutGLES.get_ok().text = tr("More Details")
	$AboutGLES.rect_size = Vector2(0, 0)
	$AboutGLES.popup_centered_minsize()

func _on_AboutGLES_confirmed() -> void:
	OS.shell_open("https://docs.godotengine.org/en/latest/tutorials/misc/gles2_gles3_differences.html")
