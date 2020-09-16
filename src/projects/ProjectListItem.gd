extends PanelContainer
class_name ProjectListItem


var project_id : String
var project_cfg : ConfigFile
var selected := false setget set_selected, get_selected
var valid := false
var project_name : String

var _path : String
var _main_scene : String

onready var path_label: Label = $HBox/VBox/Path
onready var name_label: Label = $HBox/VBox/Name
onready var icon_texture: TextureRect = $HBox/Icon
onready var version_label := $HBox/Version
onready var favorite_button: Button = $HBox/Favorite
onready var install_dialog := $Dialogs/InstallDialog
onready var edit_project_dialog := $Dialogs/EditProjectDialog
onready var last_opened := $HBox/LastOpened


func _ready() -> void:
	Projects.connect("project_changed", self, "_on_project_changed")
	Versions.connect("version_changed", self, "_on_version_changed")
	_build()


func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	if not event.pressed:
		return

	if event.doubleclick:
		if event.button_index == BUTTON_LEFT and open() == OK:
			find_parent("MainWindow").quit()
	else:
		if event.button_index == BUTTON_LEFT:
			find_parent("Projects").select_project(self, event.shift)
		elif event.button_index == BUTTON_RIGHT:
			if not selected:
				find_parent("Projects").select_project(self, false)


func open() -> int:
	if not valid:
		return ERR_CANT_OPEN

	var res := Projects.open_project(project_id)
	if res == ERR_DOES_NOT_EXIST:
		_not_installed()
	return res


func run() -> int:
	if not valid:
		return ERR_CANT_OPEN
	if not _main_scene:
		return OK

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
	if selected:
		self_modulate = Color(1, 1, 1, 1)
	else:
		self_modulate = Color(1, 1, 1, 0)


func get_selected() -> bool:
	return selected


func _on_project_changed(id: String) -> void:
	if id == project_id:
		_build()


func _on_version_changed(version: String) -> void:
	if version == Projects.get_project_version(project_id):
		_build()


func _build() -> void:
	_path = Projects.get_project_directory(project_id)
	path_label.text = _path

	project_cfg = ConfigFile.new()
	if project_cfg.load(_path.plus_file("project.godot")) != OK:
		modulate.a = .5
		name_label.text = tr("Project not found")
		return

	project_name = project_cfg.get_value("application", "config/name")
	name_label.text = project_name

	var icon = project_cfg.get_value("application", "config/icon")
	if icon:
		icon = _resolve_path(icon)
		var icon_img = Image.new()
		icon_img.load(icon)
		icon_img.resize(50, 50, Image.INTERPOLATE_CUBIC)
		var texture = ImageTexture.new()
		texture.create_from_image(icon_img)
		icon_texture.texture = texture

	var main_scene = project_cfg.get_value("application", "run/main_scene")
	if main_scene:
		_main_scene = _resolve_path(main_scene)

	var version := Projects.get_project_version(project_id)
	if Versions.exists(version):
		version_label.text = Versions.get_version_name(version)
	else:
		version_label.text = tr("Unknown version")

	if Projects.get_project_favorite(project_id):
		favorite_button.pressed = true
	else:
		favorite_button.pressed = false

	var last_opened_dt = OS.get_datetime_from_unix_time(Projects.get_project_last_opened(project_id))
	last_opened.text = "%04d-%02d-%02d" % [last_opened_dt["year"], last_opened_dt["month"], last_opened_dt["day"]]
	last_opened.hint_tooltip = "%02d:%02d" % [last_opened_dt["hour"], last_opened_dt["minute"]]

	valid = true


func _not_installed() -> void:
	var version := Projects.get_project_version(project_id)
	if Versions.exists(version):
		install_dialog.show_version_dialog(version)
	else:
		edit_project_dialog.show_dialog(project_id)


func _on_show_version() -> void:
	var version := Projects.get_project_version(project_id)
	if Versions.exists(version):
		find_parent("MainWindow").show_version(version)
	else:
		edit_project_dialog.show_dialog(project_id)


func _resolve_path(path: String) -> String:
	return path.replace("res://", _path + "/")


func _on_Favorite_toggled(button_pressed: bool) -> void:
	Projects.set_project_favorite(project_id, button_pressed)


func _on_Menu_pressed() -> void:
	find_parent("Projects").select_project(self)
	find_parent("Projects").show_menu()
