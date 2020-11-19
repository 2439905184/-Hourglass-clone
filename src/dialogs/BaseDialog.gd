class_name BaseDialog
extends Node


signal confirmed()


const CONTENTS = preload("res://src/dialogs/BaseDialogContents.tscn")


export var title: String setget set_title, get_title
export var content_size := Vector2(200, 100)
export var ok_text: String = tr("Ok") setget set_ok_text, get_ok_text
export var ok_enabled := true setget set_ok_enabled, get_ok_enabled
export var ok_shown := true setget set_ok_shown, get_ok_shown
export var cancel_text: String = tr("Cancel") setget set_cancel_text, get_cancel_text
export var cancel_shown := true setget set_cancel_shown, get_cancel_shown
export var headerbar_shown := true setget set_headerbar_shown, get_headerbar_shown


onready var colorrect := CONTENTS.instance()
onready var dialog := colorrect.get_node("Dialog")
onready var vbox := dialog.get_node("VBox")
onready var headerbar := dialog.get_node("VBox/Headerbar")
onready var title_label := dialog.get_node("VBox/Headerbar/Title")
onready var content := dialog.get_node("VBox/Content")
onready var buttons := dialog.get_node("VBox/Buttons")
onready var close := dialog.get_node("VBox/Headerbar/Close")
onready var cancel := dialog.get_node("VBox/Buttons/Cancel")
onready var ok := dialog.get_node("VBox/Buttons/Ok")


func _ready() -> void:
	# don't use our overriden add_child
	.add_child(colorrect)

	dialog.connect("popup_hide", self, "_on_Dialog_popup_hide")
	dialog.connect("about_to_show", self, "_on_Dialog_about_to_show")
	close.connect("pressed", self, "_on_Close_pressed")
	cancel.connect("pressed", self, "_on_Close_pressed")
	ok.connect("pressed", self, "_on_Ok_pressed")

	set_process(false)
	colorrect.visible = false

	title_label.text = title
	ok.text = ok_text
	ok.disabled = !ok_enabled
	set_ok_shown(ok_shown)
	cancel.text = cancel_text
	set_cancel_shown(cancel_shown)
	headerbar.visible = headerbar_shown

	# if any children were added, move them to the dialog content
	for child in get_children():
		if child != colorrect:
			child.get_parent().remove_child(child)
			content.add_child(child)


func add_child(child: Node, legible_unique_name: bool=true) -> void:
	content.add_child(child, legible_unique_name)


func get_node(path: NodePath) -> Node:
	if has_node(path):
		return .get_node(path)
	else:
		return content.get_node(path)


func _process(delta: float) -> void:
	if !dialog.visible:
		colorrect.visible = false

	set_process(false)


func set_title(new_title: String) -> void:
	title = new_title
	if title_label != null:
		title_label.text = new_title
func get_title() -> String:
	return title


func set_ok_text(new_ok_text: String) -> void:
	ok_text = new_ok_text
	if ok != null:
		ok.text = new_ok_text
func get_ok_text() -> String:
	return ok_text


func set_ok_enabled(new_ok_enabled: bool) -> void:
	ok_enabled = new_ok_enabled
	if ok != null:
		ok.disabled = !new_ok_enabled
func get_ok_enabled() -> bool:
	return ok_enabled


func set_ok_shown(new_ok_shown: bool) -> void:
	ok_shown = new_ok_shown
	if ok != null:
		ok.visible = new_ok_shown
		buttons.visible = ok_shown or cancel_shown
func get_ok_shown() -> bool:
	return ok_shown


func set_cancel_text(new_cancel_text: String) -> void:
	cancel_text = new_cancel_text
	if cancel != null:
		cancel.text = new_cancel_text
		buttons.visible = ok_shown or cancel_shown
func get_cancel_text() -> String:
	return cancel_text


func set_cancel_shown(new_cancel_shown: bool) -> void:
	cancel_shown = new_cancel_shown
	if cancel != null:
		cancel.visible = new_cancel_shown
func get_cancel_shown() -> bool:
	return cancel_shown


func set_headerbar_shown(new_headerbar_shown: bool) -> void:
	headerbar_shown = new_headerbar_shown
	if headerbar != null:
		headerbar.visible = new_headerbar_shown
func get_headerbar_shown() -> bool:
	return headerbar_shown


func show_dialog() -> void:
	dialog.popup_centered_minsize(content_size)


func _on_size_changed() -> void:
	var pos: Vector2 = (get_viewport().size - dialog.rect_size) / 2
	dialog.rect_position = pos


func _on_Dialog_popup_hide() -> void:
	get_viewport().disconnect("size_changed", self, "_on_size_changed")

	# Hide the parent ColorRect on the next main loop iteration, rather than
	# immediately. That way, the input event that closed the dialog still gets
	# blocked.
	set_process(true)


func _on_Close_pressed() -> void:
	dialog.hide()


func _on_Dialog_about_to_show() -> void:
	colorrect.visible = true
	get_viewport().connect("size_changed", self, "_on_size_changed")


func _on_Ok_pressed() -> void:
	emit_signal("confirmed")
	dialog.hide()
