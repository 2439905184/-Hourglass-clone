extends Node


signal update_started()
signal updated()
signal asset_details(asset_id)

const ASSET_STORE_GODOT := "godotengine.org"
const ASSET_STORE_GODOT_URL := "https://godotengine.org/asset-library/api"

var updating := false

var _active_updates := 0


func _ready() -> void:
	_add_store(ASSET_STORE_GODOT, ASSET_STORE_GODOT_URL)
	update()
	print(get_asset_preview("godotengine.org:579", "564"))
	print(get_asset_preview("godotengine.org:579", "564", true))


# Updates the asset library repositories.
func update(force:=false) -> void:
	updating = true

	for child in get_children():
		if child.update(force):
			_active_updates += 1

	emit_signal("update_started")


# Gets a list of all asset IDs in the store.
func get_asset_ids() -> PoolStringArray:
	var result = PoolStringArray()
	for child in get_children():
		result.append_array(child.get_asset_ids())
	return result


# Gets a property of an asset.
func get_asset_property(asset_id: String, key: String):
	var store = _get_store_by_id(asset_id)
	var id = _get_store_id(asset_id)
	return store.get_asset_property(id, key)


# Downloads the details of an asset from the API.
# The asset_details signal will be emitted with the asset
# ID when this is done.
func get_asset_details(asset_id: String, force:=false) -> void:
	var store = _get_store_by_id(asset_id)
	var id = _get_store_id(asset_id)
	store.get_asset_details(id)


# Gets the filename of an asset's icon. The file may not actually exist yet;
# listen to the `updated` signal.
func get_asset_icon(asset_id: String) -> String:
	var store = _get_store_by_id(asset_id)
	var id = _get_store_id(asset_id)
	store.get_asset_icon(id)
	return store.get_asset_icon_path(id)


# Gets the file path for an asset preview. The file may not exist yet; in that
# case, wait for the `updated` signal.
func get_asset_preview(asset_id: String, preview_id: String, thumb:=false) -> String:
	var store = _get_store_by_id(asset_id)
	var id = _get_store_id(asset_id)
	store.get_asset_preview(id, preview_id)
	return store.get_asset_preview_path(id, preview_id, thumb)


# Adds a store with an ID and URL.
func _add_store(id: String, url: String) -> void:
	var store := AssetStore.new(id, url)
	store.connect("updated", self, "_on_store_updated")
	store.connect("asset_details", self, "_on_asset_details")
	add_child(store)


# Signal handler for when an asset store has been updated.
func _on_store_updated() -> void:
	_active_updates -= 1
	if _active_updates == 0:
		print("Repositories updated")
		emit_signal("updated")


# Signal handler for when more details about an asset have been downloaded.
func _on_asset_details(asset_id: String) -> void:
	emit_signal("asset_details", asset_id)


# Gets the asset store that contains an asset.
func _get_store_by_id(asset_id: String) -> AssetStore:
	var api = asset_id.split(":", true, 1)[0]

	for child in get_children():
		if child.id == api:
			return child

	return null


# Gets the ID of an asset minus the store prefix.
func _get_store_id(asset_id: String) -> String:
	return asset_id.split(":", true, 1)[1]
