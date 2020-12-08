extends BaseDialog


var _version: String


func _ready() -> void:
	content_size = Vector2(300, 150)
	self.ok_text = tr("Install")


func show_version_dialog(version: String) -> void:
	_version = version
	self.title = tr("{version} not installed").format({"version": version})
	$Label.text = tr("{version} is not installed. Do you want to install it now?").format({"version": version})
	show_dialog()


func _on_confirmed() -> void:
	Versions.install(_version)
	find_parent("MainWindow").show_version(_version)
