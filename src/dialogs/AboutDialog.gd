extends BaseDialog


onready var version_label := $VBox/HBox/VBox/Label


func _ready() -> void:
	var build = ConfigFile.new()
	build.load("res://data/build.cfg")
	version_label.text = "Hourglass v" + build.get_value("build", "version")

	self.content_size = Vector2(500, 230)
	self.headerbar_shown = false
	self.ok_shown = false
	self.cancel_shown = false


func _on_DonateButton_pressed() -> void:
	OS.shell_open(Utils.GODOT_DONATE_LINK)


func _on_GitLabButton_pressed() -> void:
	OS.shell_open(Utils.SOURCE_LINK)
