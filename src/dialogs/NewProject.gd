extends ConfirmationDialog

onready var version_dropdown: VersionDropdown = $VBox/HBox3/VersionDropdown
onready var browse: FileDialog = $Browse
onready var name_label: Label = $VBox/HBox/Name
onready var location_label: Label = $VBox/HBox2/Location
onready var already_exists: Label = $VBox/AlreadyExists
onready var gl_version: HBoxContainer = $VBox/HBox3/GLVersion
onready var gl2: CheckBox = $VBox/HBox3/GLVersion/GL2
onready var about_gles: ConfirmationDialog = $AboutGLES


func show_dialog() -> void:
	version_dropdown.refresh()

func _ready() -> void:
	_set_name(tr("New Project"))
	_set_location(Config.get_project_location())

func _on_Browse_pressed() -> void:
	if _location_exists():
		browse.current_dir = _get_location()
	else:
		browse.current_dir = _get_location().get_base_dir()
	browse.popup_centered_minsize()

func _get_name() -> String:
	return name_label.text
func _set_name(name: String) -> void:
	name_label.text = name
	_validate()
func _get_location() -> String:
	return location_label.text
func _set_location(location: String) -> void:
	location_label.text = location
	_validate()
func _get_version() -> String:
	return version_dropdown.get_selected_version()

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
		already_exists.modulate.a = 1
		valid = false
	else:
		already_exists.modulate.a = 0

	get_ok().disabled = not valid
	return valid

func _on_Location_text_changed(_1: String) -> void:
	_validate()
func _on_Name_text_changed(_1: String) -> void:
	_validate()


func _on_version_selected(id: int) -> void:
	var version = version_dropdown.get_selected_version()
	gl_version.visible = (Versions.get_config_version(version) >= 4)

func _on_confirmed() -> void:
	if _validate():
		var creator := ProjectCreator.new()
		var ret := creator.create_project(
			_get_location(),
			_get_name(),
			_get_version(),
			gl2.pressed
		)

		if ret != OK:
			ErrorDialog.show_error("Failed to Create Project", "An error occurred while creating the project. Check the console for more information.")
			return

		ret = Projects.open_project(creator.project_id)
		if ret == OK:
			find_parent("MainWindow").quit()

func _on_About_pressed() -> void:
	about_gles.get_cancel().text = tr("Close")
	about_gles.get_ok().text = tr("More Details")
	about_gles.rect_size = Vector2(0, 0)
	about_gles.popup_centered_minsize()

func _on_AboutGLES_confirmed() -> void:
	OS.shell_open("https://docs.godotengine.org/en/latest/tutorials/misc/gles2_gles3_differences.html")
