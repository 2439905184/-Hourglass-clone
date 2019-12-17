extends HBoxContainer

var child_items := {}

func select_version(version_code: String) -> void:
	if version_code in child_items:
		child_items[version_code].select(0)


func _ready() -> void:
	$VBox.visible = false
	$VBox2/Beta.pressed = Config.show_beta_versions
	$VBox2/Mono.pressed = Config.show_mono_versions

	Versions.connect("version_installed", self, "_on_version_installed")
	Versions.connect("install_failed", self, "_on_install_failed")
	Versions.connect("download_progress", self, "_on_download_progress")

	_build_tree()

func _build_tree() -> void:
	var selected := _selected_version()
	$VBox2/Tree.clear()

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

		item.set_text(0, version)
		child_items[version] = item

	if selected:
		select_version(selected)

func _selected_version() -> String:
	var selected = $VBox2/Tree.get_selected()
	return selected.get_text(0) if selected else null

func _on_version_selected() -> void:
	var version = _selected_version()

	$VBox/HBox/Version.text = version

	var installed = Versions.is_installed(version)
	$VBox/HBox/Launch.visible = installed
	#$VBox/HBox/Remove.visible = installed
	$VBox/HBox/Install.visible = not installed

	_show_download_bar(false)

	$VBox.visible = true


func _on_Install_pressed() -> void:
	Versions.install(_selected_version())

func _on_Launch_pressed() -> void:
	Versions.launch(_selected_version(), ["--project-manager"])
	get_tree().quit()


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
