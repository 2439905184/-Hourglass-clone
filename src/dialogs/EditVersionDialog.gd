extends BaseDialog


signal version_created(version_id)

var version_id

onready var name_edit := $VBox/HBox/Name
onready var location_edit: LineEdit = $VBox/HBox2/Location
onready var browse := $Dialogs/Browse
onready var show_files := $VBox/HBox2/Show
onready var no_file_found := $VBox/NoFileFound


func _ready() -> void:
	self.content_size = Vector2(400, 200)


func show_dialog_for_version(version_id) -> void:
	self.version_id = version_id

	var name := tr("New Custom Version") if version_id == null else Versions.get_version_name(version_id)
	self.title = tr("Edit %s") % name
	name_edit.text = name

	if version_id != null and Versions.is_executable_set(version_id):
		var path := Versions.get_executable(version_id)
		location_edit.text = path
	else:
		location_edit.text = ""

	_update()
	show_dialog()


func _on_Browse_pressed() -> void:
	if not location_edit.text.empty():
		var path: String = location_edit.text
		browse.current_dir = path.get_base_dir()
		browse.current_path = path
	else:
		browse.current_dir = Config.custom_version_location

	browse.popup_centered()


func _on_Show_pressed() -> void:
	OS.shell_open(Versions.get_executable(version_id).get_base_dir())


func _on_Browse_file_selected(path: String) -> void:
	location_edit.text = path
	_update()


func _update() -> void:
	var exists := File.new().file_exists(location_edit.text)
	show_files.disabled = not exists
	no_file_found.visible = not exists
	self.ok_enabled = exists and not name_edit.text.empty()


func _on_Location_text_changed(new_text: String) -> void:
	_update()
func _on_Name_text_changed(new_text: String) -> void:
	_update()


func _on_EditVersionDialog_confirmed() -> void:
	if version_id == null:
		version_id = Versions.add_custom()
		emit_signal("version_created", version_id)

	Versions.set_version_name(version_id, name_edit.text)
	Versions.set_custom_executable(version_id, location_edit.text)
	Config.custom_version_location = location_edit.text.get_base_dir()
