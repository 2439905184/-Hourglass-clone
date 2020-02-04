extends Node

const VERSIONS_STORE = "user://versions.cfg"
const VERSIONS_TEMPLATE = "res://data/versions.cfg"

var active_downloads := 0

var _versions_store : ConfigFile

signal version_installed(version)
signal version_changed(version)
signal download_progress(version, downloaded, total)
signal install_failed(version)
signal versions_updated()

func get_versions() -> PoolStringArray:
	return _versions_store.get_sections()

func exists(version: String) -> bool:
	return _versions_store.has_section(version)

func get_version_name(version: String) -> String:
	return _versions_store.get_value(version, "name", version)

func set_version_name(version: String, new_name: String) -> void:
	_versions_store.set_value(version, "name", new_name)
	emit_signal("version_changed", version)
	_save()

func get_tags(version: String) -> PoolStringArray:
	return _versions_store.get_value(version, "tags", [])

func has_tag(version: String, tag: String) -> bool:
	for i in get_tags(version):
		if i == tag: return true
	return false

func get_download_url(version: String) -> String:
	var os := OS.get_name() + "." + ("64" if OS.has_feature("64") else "32")
	return _versions_store.get_value(version, os)

func is_installed(version: String) -> bool:
	var file := File.new()
	return file.file_exists(get_executable(version))

func get_directory(version: String) -> String:
	return OS.get_user_data_dir().plus_file("versions").plus_file(version)

func get_executable(version: String) -> String:
	if _versions_store.has_section_key(version, "executable"):
		return _versions_store.get_value(version, "executable", null)

	var exec_name := "godot.exe" if OS.get_name() == "Windows" else "godot"
	return get_directory(version).plus_file(exec_name)

func set_custom_executable(version: String, path: String) -> void:
	_versions_store.set_value(version, "executable", path)
	emit_signal("version_changed", version)
	_save()

func is_executable_set(version: String) -> bool:
	return _versions_store.has_section_key(version, "executable")

func get_config_version(version: String) -> int:
	return _versions_store.get_value(version, "config_version", 0)

func launch(version: String, args: PoolStringArray=[]) -> int:
	if not is_installed(version): return ERR_DOES_NOT_EXIST

	print("executing: ", get_executable(version), " ", args)
	OS.execute(get_executable(version), args, false)
	return OK

func run_scene(version: String, scene: String) -> void:
	launch(version, [scene])

func install(version: String) -> void:
	var download = Downloader.new(version)
	add_child(download)
	download.download()

func uninstall(version: String) -> void:
	if not is_installed(version): return

	var path := get_directory(version)
	var dir := Directory.new()

	# read the manifest and delete files listed there
	var manifest := ConfigFile.new()
	var manifest_path := path.plus_file("manifest.cfg")
	manifest.load(manifest_path)

	var to_delete := []

	to_delete += manifest.get_value("files", "GodotSharp")
	if manifest.has_section_key("files", "macOS"):
		to_delete += manifest.get_value("files", "macOS")

	# delete in reverse order, so that directories are deleted after their
	# contents
	to_delete.invert()
	for file in to_delete:
		dir.remove(path.plus_file(file))

	# delete the executable
	dir.remove(get_executable(version))
	# delete the manifest
	dir.remove(manifest_path)
	# delete the directory
	dir.remove(path)

	emit_signal("version_changed", version)


func add_custom() -> String:
	var version := Utils.uuid()
	_versions_store.set_value(version, "is_custom", true)
	_versions_store.set_value(version, "name", tr("New Custom Version"))
	emit_signal("version_installed", version)
	_save()
	return version

func is_custom(version: String) -> bool:
	return _versions_store.get_value(version, "is_custom", false)

func remove_custom_version(version: String) -> void:
	if not is_custom(version): return
	_versions_store.erase_section(version)
	emit_signal("version_changed", version)
	_save()


func _ready() -> void:
	_versions_store = ConfigFile.new()
	_versions_store.load(VERSIONS_STORE)

	var updater := VersionsUpdater.new()
	updater.connect("versions_updated", self, "_on_versions_updated")
	add_child(updater)

	_merge_versions(VERSIONS_TEMPLATE)

func _merge_versions(path: String) -> void:
	var file := ConfigFile.new()
	file.load(path)

	for section in file.get_sections():
		for key in file.get_section_keys(section):
			_versions_store.set_value(section, key, file.get_value(section, key))

	emit_signal("versions_updated")
	_save()

func _on_versions_updated() -> void:
	_merge_versions(VersionsUpdater.DOWNLOAD_PATH)
	var dir := Directory.new()
	dir.remove(VersionsUpdater.DOWNLOAD_PATH)

func _save() -> void:
	_versions_store.save(VERSIONS_STORE)
