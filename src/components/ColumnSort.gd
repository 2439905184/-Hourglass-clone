extends Control


export var disabled := false
export var text := ""
export var group: ButtonGroup
export(Config.SortMode) var sort_type := Config.SortMode.NAME

onready var label := $Panel/HBox/Label
onready var button := $Button
onready var sort_icon := $Panel/HBox/SortIcon


func _ready() -> void:
	label.text = text
	button.group = group
	button.disabled = disabled

	if Config.projects_sort == sort_type:
		button.pressed = true
	_update_sort_icon()


func _on_Button_pressed() -> void:
	var type := Config.projects_sort
	if type == sort_type:
		Config.projects_sort_ascending = !Config.projects_sort_ascending
	else:
		Config.projects_sort = sort_type
		Config.projects_sort_ascending = false

	_update_sort_icon()


func _on_Button_toggled(button_pressed: bool) -> void:
	_update_sort_icon()


func _update_sort_icon() -> void:
	if disabled:
		sort_icon.visible = false
		return

	if Config.projects_sort != sort_type or !button.pressed:
		sort_icon.visible = false
	else:
		sort_icon.visible = true
		sort_icon.flip_v = Config.projects_sort_ascending
