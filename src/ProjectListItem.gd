extends HBoxContainer
class_name ProjectListItem

var project_id : String
var project_cfg : ConfigFile
var selected := false setget set_selected, get_selected
var valid := false
var project_name : String

var _path : String
var _main_scene : String

func open() -> int:
	if not valid: return ERR_CANT_OPEN

	var res := Projects.open_project(project_id)
	if res == ERR_DOES_NOT_EXIST:
		_not_installed()
	return res

func run() -> int:
	if not valid: return ERR_CANT_OPEN
	if not _main_scene: return OK

	var res := Projects.run_project(project_id, _main_scene)
	if res == ERR_DOES_NOT_EXIST:
		_not_installed()
	return res

func show_files() -> void:
	if OS.shell_open(_path) != OK:
		ErrorDialog.show_error("Failed to Show Files", "Could not open the file browser.")

func remove() -> void:
	Projects.remove_project(project_id)

func set_selected(new_selected: bool) -> void:
	selected = new_selected
	update()

func get_selected() -> bool:
	return selected


func _ready() -> void:
	Projects.connect("project_changed", self, "_on_project_changed")
	Versions.connect("version_changed", self, "_on_version_changed")
	_build()

func _on_project_changed(id: String) -> void:
	if id == project_id:
		_build()

func _on_version_changed(version: String) -> void:
	if version == Projects.get_project_version(project_id):
		_build()

func _build() -> void:
	_path = Projects.get_project_directory(project_id)
	$VBox/Path.text = _path

	project_cfg = ConfigFile.new()
	if project_cfg.load(_path.plus_file("project.godot")) != OK:
		modulate.a = .5
		$VBox/HBox/Name.text = tr("Project not found")
		return

	project_name = project_cfg.get_value("application", "config/name")
	$VBox/HBox/Name.text = project_name

	var icon = project_cfg.get_value("application", "config/icon")
	if icon:
		icon = _resolve_path(icon)
		var icon_img = Image.new()
		icon_img.load(icon)
		icon_img.resize(50, 50, Image.INTERPOLATE_CUBIC)
		var texture = ImageTexture.new()
		texture.create_from_image(icon_img)
		$Icon.texture = texture

	var main_scene = project_cfg.get_value("application", "run/main_scene")
	if main_scene:
		_main_scene = _resolve_path(main_scene)

	var version := Projects.get_project_version(project_id)
	if Versions.exists(version):
		$VBox/HBox/Version.text = Versions.get_version_name(version)
	else:
		$VBox/HBox/Version.text = tr("Unknown version")

	valid = true

func _not_installed() -> void:
	var version := Projects.get_project_version(project_id)
	if Versions.exists(version):
		$InstallDialog.show_dialog(version)
	else:
		$EditProjectDialog.show_dialog(project_id)

func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton: return
	if not event.button_index == BUTTON_LEFT: return
	if not event.pressed: return

	if event.doubleclick:
		if open() == OK:
			find_parent("MainWindow").quit()
	else:
		find_parent("Projects").select_project(self, event.shift)

func _on_show_version() -> void:
	var version = Projects.get_project_version(project_id)
	if Versions.exists(version):
		find_parent("MainWindow").show_version(version)
	else:
		$EditProjectDialog.show_dialog(project_id)

func _resolve_path(path: String) -> String:
	return path.replace("res://", _path + "/")

func _custom_draw() -> void:
	if selected:
		var rect := Rect2(
			Vector2(-5, -5),
			get_size() + Vector2(10, 10)
		)
		draw_style_box(get_stylebox("selected", "Tree"), rect)
