extends HBoxContainer


const VERSION_LIST_ITEM = preload("res://src/versions/VersionListItem.tscn")


var search_query: String setget set_search_query, get_search_query

var _selected := []
var _child_items := {}

onready var installed := $Scroll/VBox/Installed
onready var installed_list := $Scroll/VBox/Installed/List
onready var available := $Scroll/VBox/Available
onready var available_list := $Scroll/VBox/Available/List
onready var no_results := $Scroll/VBox/NoResults
onready var edit_dialog := $EditVersionDialog


func _ready() -> void:
	Config.connect("version_settings_changed", self, "_on_version_settings_changed")

	Versions.connect("install_failed", self, "_on_install_failed")
	Versions.connect("versions_updated", self, "_on_versions_updated")
	Versions.connect("version_changed", self, "_on_version_changed")

	_build_tree()


func show_version_edit_dialog(version_id: String) -> void:
	edit_dialog.show_dialog_for_version(version_id)


func select_version_by_code(version_code: String, shift := false) -> bool:
	if not version_code in _child_items:
		return false

	select_version(_child_items[version_code])
	return true


func select_version(version: VersionListItem, shift := false) -> void:
	if not shift:
		for item in _selected:
			item.set_selected(false)
		_selected.clear()

	if shift and version.get_selected():
		_selected.remove(_selected.find(version))
		version.set_selected(false)
	else:
		_selected.append(version)
		version.set_selected(true)


func set_search_query(new_search_query: String) -> void:
	search_query = new_search_query
	_build_tree()

func get_search_query() -> String:
	return search_query


func create_custom_version() -> void:
	var version := Versions.add_custom()
	select_version_by_code(version)
	show_version_edit_dialog(version)


func _build_tree() -> void:
	var selected_ids := []
	for row in _selected:
		selected_ids.append(row.version_id)
	_selected.clear()

	for row in installed_list.get_children():
		installed_list.remove_child(row)
		row.queue_free()
	for row in available_list.get_children():
		available_list.remove_child(row)
		row.queue_free()
	_child_items.clear()

	var show_beta := Config.show_beta_versions
	var show_mono := Config.show_mono_versions

	var search := search_query

	var versions := Array(Versions.get_versions())
	versions.sort_custom(Versions, "sort_versions")
	for version in versions:
		if search != "":
			if Versions.get_version_name(version).findn(search) < 0:
				continue

		var installed := Versions.is_installed(version) or Versions.is_installing(version)
		if !installed:
			if !show_beta and Versions.has_tag(version, "beta"):
				continue
			if !show_mono and Versions.has_tag(version, "mono"):
				continue

		var item := VERSION_LIST_ITEM.instance()
		item.version_id = version
		_child_items[version] = item

		if installed:
			installed_list.add_child(item)
		else:
			available_list.add_child(item)

	for id in selected_ids:
		select_version_by_code(id, true)

	installed.visible = installed_list.get_child_count() > 0
	available.visible = available_list.get_child_count() > 0
	no_results.visible = not (installed.visible or available.visible)


func _on_versions_updated() -> void:
	_build_tree()


func _on_version_changed(_version: String) -> void:
	_child_items[_version].update()


func _on_install_failed(version: String) -> void:
	ErrorDialog.show_error("Install Failed",
			tr("Installation of {version} failed. Check the console for more information.").format({"version": version}))


func _on_version_settings_changed() -> void:
	_build_tree()
