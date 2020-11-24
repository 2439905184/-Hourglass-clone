extends BaseDialog


func _ready() -> void:
	self.content_size = Vector2(250, 120)
	self.title = tr("Cancel Downloads?")
	self.ok_text = tr("Quit")


func _on_ConfirmQuit_confirmed() -> void:
	get_tree().quit()
