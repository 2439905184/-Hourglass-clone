class_name VersionListItem
extends PanelContainer


var selected: bool setget set_selected, get_selected
var version_id: String


onready var name_label := $HBox/VBox/Name
onready var path_label := $HBox/VBox/Path
onready var buttons := $HBox/Buttons
onready var download_progress := $HBox/DownloadProgress
onready var download_label := $HBox/DownloadProgress/Label
onready var edit_button := $HBox/Edit
onready var confirm_remove := $Dialogs/ConfirmRemove
onready var confirm_uninstall := $Dialogs/ConfirmUninstall


static func instance() -> VersionListItem:
	return load("res://src/versions/VersionListItem.tscn").instance() as VersionListItem


func _ready() -> void:
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
			find_parent("Versions").select_version(self, event.shift)
		elif event.button_index == BUTTON_RIGHT:
			if not selected:
				find_parent("Versions").select_version(self, false)


func set_selected(new_selected: bool) -> void:
	selected = new_selected
	if selected:
		self_modulate = Color(1, 1, 1, 1)
	else:
		self_modulate = Color(1, 1, 1, 0)

func get_selected() -> bool:
	return selected


func open() -> int:
	return Versions.launch(version_id, ["--project-manager"])


func update() -> void:
	_build()


func _build() -> void:
	name_label.text = Versions.get_version_name(version_id)

	if Versions.is_executable_set(version_id):
		path_label.visible = true
		path_label.text = Versions.get_executable(version_id)
	else:
		path_label.visible = false

	if Versions.is_custom(version_id):
		buttons.current_tab = 3
	elif Versions.is_installed(version_id):
		buttons.current_tab = 1
	elif Versions.is_installing(version_id):
		buttons.current_tab = 2
		download_progress.visible = true
		Versions.connect("download_progress", self, "_download_progress")
	else:
		buttons.current_tab = 0

	edit_button.visible = Versions.is_custom(version_id)


func _on_Install_pressed() -> void:
	Versions.install(version_id)


func _download_progress(version: String, downloaded: int, total: int) -> void:
	if version != self.version_id:
		return

	var percent := downloaded / (total as float)
	var material: ShaderMaterial = download_progress.material
	material.set_shader_param("Progress", percent)

	# check if total > 0 because at the beginning, the total is not known yet
	if total > 0:
		var text := "%.1f / %.1f MB" % [downloaded / 1000000.0, total / 1000000.0]
		download_label.text = text


func _on_Cancel_pressed() -> void:
	Versions.cancel_install(version_id)


func _on_Edit_pressed() -> void:
	find_parent("Versions").show_version_edit_dialog(version_id)


func _on_Remove_pressed() -> void:
	var version := Versions.get_version_name(version_id)

	confirm_remove.get_ok().text = tr("Remove")
	confirm_remove.dialog_text = tr("Are you sure you want to remove the custom version {version}? No files will be deleted.").format({"version": version})
	confirm_remove.window_title = tr("Remove {version}?").format({"version": version})
	confirm_remove.rect_size = Vector2(0, 0)
	confirm_remove.popup_centered_minsize()


func _on_ConfirmRemove_confirmed() -> void:
	Versions.remove_custom_version(version_id)


func _on_Uninstall_pressed() -> void:
	var version := Versions.get_version_name(version_id)

	confirm_uninstall.get_ok().text = tr("Uninstall")
	confirm_uninstall.dialog_text = tr("Are you sure you want to uninstall {version}?").format({"version": version})
	confirm_uninstall.window_title = tr("Uninstall {version}?").format({"version": version})
	confirm_uninstall.rect_size = Vector2(0, 0)
	confirm_uninstall.popup_centered_minsize()


func _on_ConfirmUninstall_confirmed() -> void:
	Versions.uninstall(version_id)
