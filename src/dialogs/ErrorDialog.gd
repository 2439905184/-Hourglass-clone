extends AcceptDialog


onready var label: Label = Label.new()


func _ready() -> void:
	label.name = "Label"
	label.autowrap = true
	add_child(label)

	rect_min_size = Vector2(300, 0)

func show_error(title: String, error: String) -> void:
	window_title = tr(title)
	label.text = tr(error)

	rect_size = Vector2(0, 0)
	popup_centered()
