extends BaseDialog


onready var version_label := $VBox/HBox/VBox/Label


func _ready() -> void:
	var build = ConfigFile.new()
	build.load("res://data/build.cfg")
	version_label.text = "Hourglass v" + build.get_value("build", "version")


func _on_DonateButton_pressed() -> void:
	OS.shell_open(Utils.GODOT_DONATE_LINK)


func _on_GitLabButton_pressed() -> void:
	OS.shell_open(Utils.SOURCE_LINK)
