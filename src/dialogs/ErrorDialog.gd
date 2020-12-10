extends BaseDialog


onready var label := Label.new()


func _init() -> void:
	content_size = Vector2(300, 150)
	cancel_shown = false


func _ready() -> void:
	label.name = "Label"
	label.autowrap = true
	add_child(label)


func show_error(title: String, error: String) -> void:
	self.title = tr(title)
	label.text = tr(error)

	self.show_dialog()
