extends Node

const VERSIONS_CFG = "res://data/versions.cfg"
const VERSIONS_STORE = "user://installed_versions.cfg"

var _versions_cfg : ConfigFile
var _versions_store : ConfigFile

signal version_installed(version)
signal download_progress(version, downloaded, total)
signal install_failed(version)

func get_versions() -> PoolStringArray:
	return _versions_cfg.get_sections()

func get_tags(version: String) -> PoolStringArray:
	return _versions_cfg.get_value(version, "tags", [])

func has_tag(version: String, tag: String) -> bool:
	for i in get_tags(version):
		if i == tag: return true
	return false

func get_download_url(version: String) -> String:
	var os := OS.get_name() + "." + ("64" if OS.has_feature("64") else "32")
	return _versions_cfg.get_value(version, os)

func is_installed(version: String) -> bool:
	var file := File.new()
	return file.file_exists(get_executable(version))

func get_directory(version: String) -> String:
	return OS.get_user_data_dir().plus_file("versions").plus_file(version)

func get_executable(version: String) -> String:
	var exec_name := "godot.exe" if OS.get_name() == "Windows" else "godot"
	return get_directory(version).plus_file(exec_name)

func get_config_version(version: String) -> int:
	return _versions_cfg.get_value(version, "config_version")

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

func _ready() -> void:
	_versions_cfg = ConfigFile.new()
	_versions_cfg.load(VERSIONS_CFG)

func _save() -> void:
	_versions_store.save(VERSIONS_STORE)
