extends ConfirmationDialog


func _ready() -> void:
	get_ok().text = tr("Quit")


func _on_ConfirmQuit_confirmed() -> void:
	get_tree().quit()


func _on_ConfirmQuit_about_to_show() -> void:
	rect_size = Vector2(0, 0)
