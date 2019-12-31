extends Control

func show_version(version_code: String) -> void:
	$TabContainer/Versions.select_version(version_code)
	$TabContainer.current_tab = 1

func _ready() -> void:
	var build = ConfigFile.new()
	build.load("res://data/build.cfg")
	$HBox/Version.text = "v" + build.get_value("build", "version")

	$ConfirmQuit.get_ok().text = tr("Quit")
	get_tree().set_auto_accept_quit(false)

func _on_Version_pressed() -> void:
	OS.shell_open("https://gitlab.com/FlyingPiMonster/godot-version-manager")


func _notification(what: int) -> void:
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if _should_ask_before_quitting():
			$ConfirmQuit.rect_size = Vector2(0, 0)
			$ConfirmQuit.popup_centered()
		else:
			get_tree().quit()

func _should_ask_before_quitting() -> bool:
	return Versions.active_downloads != 0

func quit() -> void:
	if !_should_ask_before_quitting():
		get_tree().quit()

func _on_ConfirmQuit_confirmed() -> void:
	get_tree().quit()
