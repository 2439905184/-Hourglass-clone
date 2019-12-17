extends ConfirmationDialog

var _version : String

func _ready() -> void:
	get_ok().text = tr("Install")

func show_dialog(version: String) -> void:
	_version = version
	window_title = tr("{version} not installed").format({"version": version})
	dialog_text = tr("{version} is not installed. Do you want to install it now?").format({"version": version})
	rect_size = Vector2(0, 0)
	popup_centered_minsize()


func _on_confirmed() -> void:
	Versions.install(_version)
	find_parent("MainWindow").show_version(_version)
