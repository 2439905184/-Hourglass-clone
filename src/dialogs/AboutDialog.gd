extends BaseDialog


onready var version_label := $VBox/HBox/VBox/Label
onready var update_panel := $VBox/VBox/Update
onready var update_text := $VBox/VBox/Update/VBox/UpdateText


func _ready() -> void:
	version_label.text = "Hourglass v" + str(Updater.current_version)

	self.content_size = Vector2(500, 300)
	self.headerbar_shown = false
	self.ok_shown = false
	self.cancel_shown = false

	Updater.connect("update_found", self, "_on_update_found")


func _on_DonateButton_pressed() -> void:
	OS.shell_open(Utils.GODOT_DONATE_LINK)


func _on_GitLabButton_pressed() -> void:
	OS.shell_open(Utils.SOURCE_LINK)


func _on_UpdateButton_pressed() -> void:
	OS.shell_open(Utils.UPDATE_LINK)


func _on_update_found(new_version: String) -> void:
	update_panel.visible = true
	update_text.text = tr("Hourglass v%s is available! Click here to download." % new_version)
