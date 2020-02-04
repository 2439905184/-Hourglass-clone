extends Control


onready var confirm_quit: Button = $ConfirmQuit
onready var versions: HBoxContainer = $TabContainer/Versions
onready var tab_container: TabContainer = $TabContainer
onready var version_label: Label = $HBox/Version


func show_version(version_code: String) -> void:
	versions.select_version(version_code)
	tab_container.current_tab = 1

func _ready() -> void:
	var build = ConfigFile.new()
	build.load("res://data/build.cfg")
	version_label.text = "v" + build.get_value("build", "version")

	confirm_quit.get_ok().text = tr("Quit")
	get_tree().set_auto_accept_quit(false)

func _on_Version_pressed() -> void:
	OS.shell_open("https://hourglass.flyingpimonster.net")


func _notification(what: int) -> void:
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if _should_ask_before_quitting():
			confirm_quit.rect_size = Vector2(0, 0)
			confirm_quit.popup_centered()
		else:
			get_tree().quit()

func _should_ask_before_quitting() -> bool:
	return Versions.active_downloads != 0

func quit() -> void:
	if !_should_ask_before_quitting():
		get_tree().quit()

func _on_ConfirmQuit_confirmed() -> void:
	get_tree().quit()
