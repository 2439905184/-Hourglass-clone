extends PanelContainer
class_name SearchBar

signal search_changed(new_text)
signal search_entered(new_text)
signal search_change_rejected()
signal search_cleared()

onready var _line_edit := $HBoxContainer/LineEdit

func _on_LineEdit_text_changed(new_text: String) -> void:
	emit_signal("search_changed", new_text)


func _on_LineEdit_text_entered(new_text: String) -> void:
	emit_signal("search_entered", new_text)


func _on_LineEdit_text_change_rejected() -> void:
	emit_signal("search_change_rejected")


func _on_Delete_pressed() -> void:
	_line_edit.clear()
	emit_signal("search_cleared")
