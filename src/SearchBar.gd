extends PanelContainer
class_name SearchBar


signal search_changed(new_text)
signal search_entered(new_text)
signal search_change_rejected()
signal search_cleared()

var text setget set_text, get_text
var placeholder_text setget set_placeholder_text, get_placeholder_text

onready var line_edit := $HBoxContainer/LineEdit
onready var clear_button := $HBoxContainer/Delete


func clear() -> void:
	line_edit.clear()


func set_text(new_text: String) -> void:
	if new_text != line_edit.text:
		line_edit.text = new_text
	clear_button.visible = !new_text.empty()


func get_text() -> String:
	return line_edit.text


func set_placeholder_text(new_placeholder_text: String) -> void:
	line_edit.placeholder_text = new_placeholder_text

func get_placeholder_text() -> String:
	return line_edit.placeholder_text


func _on_LineEdit_text_changed(new_text: String) -> void:
	emit_signal("search_changed", new_text)
	clear_button.visible = !new_text.empty()


func _on_Delete_pressed() -> void:
	clear()
