extends PopupDialog


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		print("MOUSE BUTTON INPUT")
