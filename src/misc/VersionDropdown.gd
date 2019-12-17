extends OptionButton

var selected_version : String setget set_selected_version, get_selected_version

func set_selected_version(new_selected_version: String) -> void:
	for idx in range(get_item_count()):
		if get_item_metadata(idx) == new_selected_version:
			select(idx)
			return

func get_selected_version() -> String:
	return get_item_text(selected)

func refresh() -> void:
	clear()
	for version in Versions.get_versions():
		if Versions.is_installed(version):
			add_item(version)
			set_item_metadata(get_item_count() - 1, version)

func _ready() -> void:
	refresh()
