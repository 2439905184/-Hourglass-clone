extends HBoxContainer

var child_items := {}

func select_version(version_code: String) -> bool:
	if version_code in child_items:
		child_items[version_code].select(0)
		return true
	return false


func _ready() -> void:
	$VBox.visible = false
	$VBox2/Beta.pressed = Config.show_beta_versions
	$VBox2/Mono.pressed = Config.show_mono_versions

	Versions.connect("version_installed", self, "_on_version_installed")
	Versions.connect("install_failed", self, "_on_install_failed")
	Versions.connect("download_progress", self, "_on_download_progress")
	Versions.connect("versions_updated", self, "_on_versions_updated")
	Versions.connect("version_changed", self, "_on_version_changed")

	_build_tree()

func _build_tree() -> void:
	var selected := _selected_version()
	$VBox2/Tree.clear()
	child_items.clear()

	var root = $VBox2/Tree.create_item()

	var installed = $VBox2/Tree.create_item(root)
	installed.set_text(0, tr("Installed"))
	installed.set_selectable(0, false)

	var available = $VBox2/Tree.create_item(root)
	available.set_text(0, tr("Available"))
	available.set_selectable(0, false)

	var beta := Config.show_beta_versions
	var mono := Config.show_mono_versions

	for version in Versions.get_versions():
		var item
		if Versions.is_installed(version):
			item = $VBox2/Tree.create_item(installed)
		else:
			if !beta and Versions.has_tag(version, "beta"):
				continue
			if !mono and Versions.has_tag(version, "mono"):
				continue

			item = $VBox2/Tree.create_item(available)

		item.set_text(0, Versions.get_version_name(version))
		item.set_metadata(0, version)
		child_items[version] = item

	if selected:
		if not select_version(selected):
			_on_version_selected()

func _selected_version() -> String:
	var selected = $VBox2/Tree.get_selected()
	return selected.get_metadata(0) if selected else null

func _on_version_selected() -> void:
	var version = _selected_version()
	if not version:
		$VBox.visible = false
		return

	$VBox/HBox/Version.text = Versions.get_version_name(version)

	var installed = Versions.is_installed(version)
	var custom = Versions.is_custom(version)
	$VBox/HBox/Launch.visible = installed
	$VBox/HBox/Install.visible = (not installed) and (not custom)
	#$VBox/HBox/Uninstall.visible = installed and not custom
	$VBox/HBox/Remove.visible = custom

	if Versions.is_custom(version):
		$VBox/EditCustom.visible = true
		$VBox/EditCustom/HBox/Executable.text = Versions.get_executable(version)
		$VBox/EditCustom/HBox2/Name.text = Versions.get_version_name(version)

		if Versions.is_executable_set(version):
			$VBox/EditCustom/HBox/ShowExecutable.disabled = false
			$VBox/EditCustom/HBox/Executable.align = Label.ALIGN_RIGHT
		else:
			$VBox/EditCustom/HBox/ShowExecutable.disabled = true
			$VBox/EditCustom/HBox/Executable.align = Label.ALIGN_LEFT
			$VBox/EditCustom/HBox/Executable.text = tr("No executable selected")
	else:
		$VBox/EditCustom.visible = false

	_show_download_bar(false)

	$VBox.visible = true


func _on_Install_pressed() -> void:
	Versions.install(_selected_version())

func _on_Launch_pressed() -> void:
	Versions.launch(_selected_version(), ["--project-manager"])
	get_tree().quit()

func _on_Uninstall_pressed() -> void:
	pass # Replace with function body.

func _on_Remove_pressed() -> void:
	var version := Versions.get_version_name(_selected_version())
	var dialog = $VBox/HBox/ConfirmRemove

	dialog.get_ok().text = tr("Remove")
	dialog.dialog_text = tr("Are you sure you want to remove the custom version {version}? No files will be deleted.").format({"version": version})
	dialog.window_title = tr("Remove {version}?").format({"version": version})
	dialog.rect_size = Vector2(0, 0)
	dialog.popup_centered_minsize()

func _on_ConfirmRemove_confirmed() -> void:
	Versions.remove_custom_version(_selected_version())


func _on_Beta_toggled(pressed: bool) -> void:
	Config.show_beta_versions = pressed
	_build_tree()

func _on_Mono_toggled(pressed: bool) -> void:
	Config.show_mono_versions = pressed
	_build_tree()

func _on_version_installed(version: String) -> void:
	_build_tree()
	if version == _selected_version():
		_show_download_bar(false)

func _on_versions_updated() -> void:
	_build_tree()

func _on_version_changed(_version: String) -> void:
	_build_tree()

func _on_install_failed(version: String) -> void:
	ErrorDialog.show_error(
		"Install Failed",
		tr("Installation of {version} failed. Check the console for more information.").format({"version": version})
	)

func _show_download_bar(show: bool) -> void:
	$VBox/HBox/DownloadProgress.visible = show
	$VBox/HBox/spacer.visible = !show

func _on_download_progress(version: String, downloaded: int, total: int) -> void:
	if version != _selected_version(): return
	if total <= 0: return

	_show_download_bar(true)
	$VBox/HBox/DownloadProgress.value = (downloaded / float(total))
	var text = "%.1f / %.1f MB" % [downloaded / 1000000.0, total / 1000000.0]
	$VBox/HBox/DownloadProgress/Label.text = text

func _on_AddCustom_pressed() -> void:
	var version := Versions.add_custom()
	select_version(version)

func _on_Name_text_entered(new_text: String) -> void:
	_on_Rename_pressed()

func _on_Rename_pressed() -> void:
	var version := _selected_version()
	Versions.set_version_name(version, $VBox/EditCustom/HBox2/Name.text)

func _on_ShowExecutable_pressed() -> void:
	OS.shell_open(Versions.get_executable(_selected_version()).get_base_dir())

func _on_Browse_pressed() -> void:
	var dialog = $VBox/EditCustom/HBox/BrowseDialog
	var version = _selected_version()

	if Versions.is_executable_set(version):
		var path := Versions.get_executable(version)
		dialog.current_dir = path.get_base_dir()
		dialog.current_path = path
	else:
		dialog.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)

	dialog.filters = [
		"godot.*.exe" if OS.get_name() == "Windows" else "godot.*"
	]
	dialog.popup_centered()

func _on_BrowseDialog_file_selected(path: String) -> void:
	Versions.set_custom_executable(_selected_version(), path)
