extends PanelContainer
class_name SearchBar


signal search_changed(new_text)
signal search_entered(new_text)
signal search_change_rejected()
signal search_cleared()

var text setget set_text, get_text

onready var line_edit := $HBoxContainer/LineEdit


func clear() -> void:
	line_edit.clear()


func set_text(new_text: String) -> void:
	if new_text != line_edit.text:
		line_edit.text = new_text


func get_text() -> String:
	return line_edit.text


func _on_LineEdit_text_changed(new_text: String) -> void:
	emit_signal("search_changed", new_text)


func _on_Delete_pressed() -> void:
	clear()
