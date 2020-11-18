extends BaseDialog


func _on_ConfirmQuit_confirmed() -> void:
	get_tree().quit()
