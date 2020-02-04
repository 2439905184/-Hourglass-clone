extends HBoxContainer


var _child_items := {}

onready var main_pane: VBoxContainer = $MainPane
onready var side_pane: VBoxContainer = $SidePane
onready var beta: CheckBox = $SidePane/Beta
onready var mono: CheckBox = $SidePane/Mono
onready var tree: Tree = $SidePane/Tree
onready var search_box: LineEdit = $SidePane/Search
onready var version_label: Label = $MainPane/HBox/Version
onready var version_launch: Label = $MainPane/HBox/Launch
onready var version_install: Button = $MainPane/HBox/Install
onready var version_uninstall: Button = $MainPane/HBox/Uninstall
onready var version_uninstall_confirm: ConfirmationDialog = $MainPane/HBox/ConfirmUninstall
onready var version_remove: Button = $MainPane/HBox/Remove
onready var version_remove_confirm: ConfirmationDialog = $MainPane/HBox/ConfirmRemove
onready var custom_edit: GridContainer = $MainPane/EditCustom
onready var custom_executable: LineEdit = $MainPane/EditCustom/HBox/Executable
onready var custom_name: LineEdit = $MainPane/EditCustom/HBox2/Name
onready var custom_executable_show: Button = $MainPane/EditCustom/HBox/ShowExecutable
onready var custom_browse: FileDialog = $MainPane/EditCustom/HBox/BrowseDialog
onready var download_progress: ProgressBar = $MainPane/HBox/DownloadProgress
onready var download_progress_label: Label = $MainPane/HBox/DownloadProgress/Label
onready var download_spacer: Control = $MainPane/HBox/spacer


func _ready() -> void:
	main_pane.visible = false
	beta.pressed = Config.show_beta_versions
	mono.pressed = Config.show_mono_versions

	Versions.connect("version_installed", self, "_on_version_installed")
	Versions.connect("install_failed", self, "_on_install_failed")
	Versions.connect("download_progress", self, "_on_download_progress")
	Versions.connect("versions_updated", self, "_on_versions_updated")
	Versions.connect("version_changed", self, "_on_version_changed")

	_build_tree()

func select_version(version_code: String) -> bool:
	if version_code in _child_items:
		_child_items[version_code].select(0)
		return true
	return false

func _build_tree() -> void:
	var selected := _selected_version()
	tree.clear()
	_child_items.clear()

	var root := tree.create_item()

	var installed := tree.create_item(root)
	installed.set_text(0, tr("Installed"))
	installed.set_selectable(0, false)

	var available := tree.create_item(root)
	available.set_text(0, tr("Available"))
	available.set_selectable(0, false)

	var beta := Config.show_beta_versions
	var mono := Config.show_mono_versions

	var search := search_box.text

	for version in Versions.get_versions():
		if search != "":
			if Versions.get_version_name(version).findn(search) < 0:
				continue

		var item: TreeItem
		if Versions.is_installed(version):
			item = tree.create_item(installed)
		else:
			if !beta and Versions.has_tag(version, "beta"):
				continue
			if !mono and Versions.has_tag(version, "mono"):
				continue

			item = tree.create_item(available)

		item.set_text(0, Versions.get_version_name(version))
		item.set_metadata(0, version)
		_child_items[version] = item

	if selected:
		if not select_version(selected):
			_on_version_selected()

func _selected_version() -> String:
	var selected := tree.get_selected()
	return selected.get_metadata(0) if selected else null

func _on_version_selected() -> void:
	var version := _selected_version()
	if not version:
		main_pane.visible = false
		return

	version_label.text = Versions.get_version_name(version)

	var installed := Versions.is_installed(version)
	var custom := Versions.is_custom(version)
	version_launch.visible = installed
	version_install.visible = (not installed) and (not custom)
	version_uninstall.visible = installed and not custom
	version_remove.visible = custom

	if Versions.is_custom(version):
		custom_edit.visible = true
		custom_executable.text = Versions.get_executable(version)
		custom_name.text = Versions.get_version_name(version)

		if Versions.is_executable_set(version):
			custom_executable_show.disabled = false
			custom_executable.align = Label.ALIGN_RIGHT
		else:
			custom_executable_show.disabled = true
			custom_executable.align = Label.ALIGN_LEFT
			custom_executable.text = tr("No executable selected")
	else:
		custom_edit.visible = false

	_show_download_bar(false)

	main_pane.visible = true


func _on_Install_pressed() -> void:
	Versions.install(_selected_version())

func _on_Launch_pressed() -> void:
	Versions.launch(_selected_version(), ["--project-manager"])
	find_parent("MainWindow").quit()

func _on_Uninstall_pressed() -> void:
	var version := Versions.get_version_name(_selected_version())
	var dialog := version_uninstall_confirm

	dialog.get_ok().text = tr("Uninstall")
	dialog.dialog_text = tr("Are you sure you want to uninstall {version}?").format({"version": version})
	dialog.window_title = tr("Uninstall {version}?").format({"version": version})
	dialog.rect_size = Vector2(0, 0)
	dialog.popup_centered_minsize()

func _on_ConfirmUninstall_confirmed() -> void:
	Versions.uninstall(_selected_version())

func _on_Remove_pressed() -> void:
	var version := Versions.get_version_name(_selected_version())
	var dialog := version_remove_confirm

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
	ErrorDialog.show_error("Install Failed",
			tr("Installation of {version} failed. Check the console for more information.").format({"version": version}))

func _show_download_bar(show: bool) -> void:
	download_progress.visible = show
	download_spacer.visible = !show
	if show:
		version_install.visible = false

func _on_download_progress(version: String, downloaded: int, total: int) -> void:
	if version != _selected_version():
		return
	if total <= 0:
		return

	_show_download_bar(true)
	download_progress.value = (downloaded / float(total))
	var text := "%.1f / %.1f MB" % [downloaded / 1000000.0, total / 1000000.0]
	download_progress_label.text = text

func _on_AddCustom_pressed() -> void:
	var version := Versions.add_custom()
	select_version(version)

func _on_Name_text_entered(new_text: String) -> void:
	_on_Rename_pressed()

func _on_Rename_pressed() -> void:
	var version := _selected_version()
	Versions.set_version_name(version, custom_name.text)

func _on_ShowExecutable_pressed() -> void:
	OS.shell_open(Versions.get_executable(_selected_version()).get_base_dir())

func _on_Browse_pressed() -> void:
	var version := _selected_version()

	if Versions.is_executable_set(version):
		var path := Versions.get_executable(version)
		custom_browse.current_dir = path.get_base_dir()
		custom_browse.current_path = path
	else:
		custom_browse.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)

	custom_browse.filters = [
		"godot.*.exe" if OS.get_name() == "Windows" else "godot.*"
	]
	custom_browse.popup_centered()

func _on_BrowseDialog_file_selected(path: String) -> void:
	Versions.set_custom_executable(_selected_version(), path)

func _on_Search_text_changed(new_text: String) -> void:
	_build_tree()
