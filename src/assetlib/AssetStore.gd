class_name AssetStore
extends Node


signal updated()
signal asset_details(asset_id)

const ASSET_SEARCH = "/asset?type=any&godot_version=any&max_results=500"
const CACHE_LENGTH = 3600 * 24

var id: String

var _url: String

var _config: ConfigFile
var _config_file: String


func _init(id: String, url: String) -> void:
	_url = url
	self.id = id

	_config_file = "user://assetlib/" + id + "/repository.cfg"
	_config = ConfigFile.new()
	_config.load(_config_file)


# Begins updating the repository.
func update(force:=false) -> bool:
	if _check_update_needed("repository", force):
		print("Updating repository " + id)
		_config = ConfigFile.new()
		_download("/configure?type=any", "_configure_cb")
		return true
	else:
		return false


# Returns a list of all asset IDs in this store (including the store prefix).
func get_asset_ids() -> PoolStringArray:
	var result = PoolStringArray()
	for section in _config.get_sections():
		if section.begins_with("asset:"):
			result.append(self.id + ":" + section.split(":", true, 1)[1])

	return result


# Gets a property of an asset.
func get_asset_property(id: String, key: String):
	return _config.get_value("asset:" + id, key)


# Starts retrieving more information about an asset (description, download
# URLs, etc.)
func get_asset_details(id: String, force:=false) -> void:
	if _check_update_needed("asset:" + id, force):
		_download("/asset/" + id, "_asset_cb")
	else:
		emit_signal("asset_details", self.id + ":" + id)


# Gets the location where an asset's icon will be saved.
func get_asset_icon_path(id: String) -> String:
	return "user://assetlib/" + self.id + "/" + id + "_icon"


# Retrieves an asset's icon.
# When this is done, if nothing failed, the icon will be saved to a file. You
# can find the path to this file using get_icon_path().
func get_asset_icon(id: String) -> void:
	var path = get_asset_icon_path(id)

	if not _check_file_update_needed(path):
		# Icon is already downloaded and up to date
		emit_signal("updated")
		return

	var url = get_asset_property(id, "icon_url")
	if url != null:
		_download_image(url, path)
	else:
		print("Asset " + self.id + ":" + id + " has no icon name")


func get_asset_preview_path(id: String, preview_id: String, thumb:=false) -> String:
	var link = "user://assetlib/" + self.id + "/" + id + "_preview_" + preview_id
	var previews = get_asset_property(id, "previews")
	if previews == null:
		return link

	for preview in previews:
		if preview.preview_id == preview_id:
			if preview.link == preview.thumbnail:
				# thumbnail is the same as the link. use the preview even if
				# asked for the thumbnail
				return link
			else:
				break

	if thumb:
		return "user://assetlib/" + self.id + "/" + id + "_preview_" + preview_id + "_thumb"
	else:
		return link


func get_asset_preview(id: String, preview_id: String, thumb:=false) -> void:
	var previews = get_asset_property(id, "previews")
	if previews == null:
		return

	var path = get_asset_preview_path(id, preview_id, thumb)

	if not _check_file_update_needed(path):
		# Icon is already downloaded and up to date
		emit_signal("updated")
		return

	var url: String
	for preview in previews:
		if preview.preview_id == preview_id:
			url = preview.thumbnail if thumb else preview.link
			break

	if url != null:
		_download_image(url, path)
	else:
		print("Asset " + self.id + ":" + id + " has no preview #" + preview_id)


# Downloads a file and calls a method when finished.
func _download(path: String, method: String) -> void:
	var request := HTTPRequest.new()
	add_child(request)

	var url := _url + path

	request.connect(
		"request_completed", self, "_on_request_completed",
		[url, method, request]
	)

	if request.request(url) != OK:
		push_error("Fetch repository failed for " + id + "!")
		push_error("Request URL: " + url)
		push_error("Could not initiate request!")


func _on_request_completed(result: int, response: int,
						   headers: PoolStringArray, body: PoolByteArray,
						   url: String, method: String,
						   request: HTTPRequest, userdata=null) -> void:

	remove_child(request)

	if result != OK:
		push_error("Fetch repository failed for " + id + "!")
		push_error("Request URL: " + url)
		push_error("Connection error: " + str(result) + " (see https://docs.godotengine.org/en/3.1/classes/class_httprequest.html#enumerations)")
		return
	elif response != 200:
		push_error("Fetch repository failed for " + id + "!")
		push_error("Request URL: " + url)
		push_error("HTTP status code " + str(response))
		return

	var json := JSON.parse(body.get_string_from_utf8())
	if json.error == OK:
		if userdata != null:
			call(method, json.result, userdata)
		else:
			call(method, json.result)
	else:
		push_error("Fetch repository failed for " + id + "!")
		push_error("Request URL: " + url)
		push_error("Malformed JSON (line " + str(json.error_line) + ": " + json.error_string + ")")
		return


# Downloads an image and saves it to a file. The `updated` signal will be
# emitted when this is done.
func _download_image(url: String, file: String) -> void:
	var request := HTTPRequest.new()
	add_child(request)

	request.download_file = file
	request.connect(
		"request_completed", self, "_on_image_downloaded",
		[url, request]
	)

	if request.request(url) != OK:
		push_error("Fetch image failed for " + id + "!")
		push_error("Request URL: " + url)
		push_error("Could not initiate request!")


func _on_image_downloaded(result: int, response: int,
						  headers: PoolStringArray, body: PoolByteArray,
						  url: String, request: HTTPRequest):

	remove_child(request)

	if result != OK:
		push_error("Fetch image failed for " + id + "!")
		push_error("Request URL: " + url)
		push_error("Connection error: " + str(result) + " (see https://docs.godotengine.org/en/3.1/classes/class_httprequest.html#enumerations)")
		return
	elif response != 200:
		push_error("Fetch image failed for " + id + "!")
		push_error("Request URL: " + url)
		push_error("HTTP status code " + str(response))
		return

	emit_signal("updated")


func _configure_cb(configure) -> void:
	var categories: Array = configure["categories"]

	for category in categories:
		var section: String = "category:" + category["id"]
		_dict_to_config(section, category)

	_download(ASSET_SEARCH, "_asset_page_cb")


func _asset_page_cb(page) -> void:
	var assets: Array = page["result"]

	for asset in assets:
		var section: String = "asset:" + asset["asset_id"]
		_dict_to_config(section, asset)

	var pagenum: int = page["page"]
	var pagecount: int = page["pages"]
	pagenum += 1
	if pagenum < pagecount:
		_download(ASSET_SEARCH + "&page=" + str(pagenum), "_asset_page_cb")
	else:
		_config.set_value("repository", "last_repository_update", OS.get_system_time_secs())
		_save()
		emit_signal("updated")


func _asset_cb(asset) -> void:
	var section: String = "asset:" + asset["asset_id"]
	_dict_to_config(section, asset)
	_set_updated(section)
	_save()
	emit_signal("asset_details", id + ":" + asset["asset_id"])


# Writes the items in a dictionary to the config file under section.
func _dict_to_config(section: String, dict: Dictionary) -> void:
	for key in dict:
		_config.set_value(section, key, dict[key])


# Check whether the "last_repository_update" key of the given section is older
# than CACHE_LENGTH.
func _check_update_needed(section: String, force: bool) -> bool:
	if force:
		return true

	var last: int = _config.get_value(section, "last_repository_update", 0)
	return (OS.get_system_time_secs() - last) > CACHE_LENGTH


# Checks whether the given file either doesn't exist or is older than the
# cache length.
func _check_file_update_needed(path: String) -> bool:
	var file := File.new()
	if not file.file_exists(path):
		return true

	var modified := file.get_modified_time(path)
	return (OS.get_system_time_secs() - modified) > CACHE_LENGTH


# Sets the "last_repository_update" timestamp of the given section.
func _set_updated(section: String) -> void:
	_config.set_value(section, "last_repository_update", OS.get_system_time_secs())


# Saves the config file.
func _save() -> void:
	var dir := Directory.new()
	dir.make_dir_recursive(_config_file.get_base_dir())

	_config.save(_config_file)
