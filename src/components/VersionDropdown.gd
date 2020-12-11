class_name VersionDropdown
extends OptionButton


var selected_version: String setget set_selected_version, get_selected_version


func _ready() -> void:
	Versions.connect("versions_updated", self, "refresh")
	refresh()


func set_selected_version(new_selected_version: String) -> void:
	for idx in range(get_item_count()):
		if get_item_metadata(idx) == new_selected_version:
			select(idx)
			return


func get_selected_version() -> String:
	return get_item_metadata(selected)


func refresh() -> void:
	var selected = get_selected_version()
	clear()

	var versions := Array(Versions.get_versions())
	versions.sort_custom(Versions, "sort_versions")
	for version in versions:
		if Versions.is_installed(version):
			add_item(Versions.get_version_name(version))
			set_item_metadata(get_item_count() - 1, version)

	if selected:
		set_selected_version(selected)
