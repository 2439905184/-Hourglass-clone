extends BaseDialog


var version_id: String

onready var name_edit := $VBox/HBox/Name
onready var location_edit := $VBox/HBox2/Location
onready var browse := $Dialogs/Browse
onready var show_files := $VBox/HBox2/Show


func _ready() -> void:
	self.content_size = Vector2(400, 200)
	self.cancel_shown = false


func show_dialog_for_version(version_id: String) -> void:
	self.version_id = version_id
	_update_name()
	_update_location()

	show_dialog()


func _update_name(lineedit:=true) -> void:
	var name := Versions.get_version_name(version_id)
	self.title = tr("Edit %s") % name
	if lineedit:
		name_edit.text = name


func _update_location(lineedit:=true) -> void:
	if Versions.is_executable_set(version_id):
		var path := Versions.get_executable(version_id)

		if lineedit:
			location_edit.text = path

		var exists := File.new().file_exists(path)
		show_files.disabled = !exists
	else:
		show_files.disabled = true


func _on_Browse_pressed() -> void:
	if Versions.is_executable_set(version_id):
		var path := Versions.get_executable(version_id)
		browse.current_dir = path.get_base_dir()
		browse.current_path = path
	else:
		browse.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)

	browse.popup_centered()


func _on_Show_pressed() -> void:
	OS.shell_open(Versions.get_executable(version_id).get_base_dir())


func _on_Browse_file_selected(path: String) -> void:
	Versions.set_custom_executable(version_id, path)
	_update_location()


func _on_Name_text_changed(new_text: String) -> void:
	Versions.set_version_name(version_id, new_text)
	_update_name(false)


func _on_Location_text_changed(new_text: String) -> void:
	Versions.set_custom_executable(version_id, new_text)
	_update_location(false)
