extends Node

var project_location : String setget set_project_location, get_project_location
var show_beta_versions : bool setget set_show_beta_versions, get_show_beta_versions
var show_mono_versions : bool setget set_show_mono_versions, get_show_mono_versions
var sort_mode : int setget set_sort_mode, get_sort_mode


const CONFIG_FILE = "user://options.cfg"
var _config : ConfigFile


func _ready() -> void:
	_config = ConfigFile.new()
	_config.load(CONFIG_FILE)

func save() -> void:
	_config.save(CONFIG_FILE)

func get_project_location() -> String:
	return _config.get_value("general", "project_location", OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS))

func set_project_location(new_project_location: String) -> void:
	_config.set_value("general", "project_location", new_project_location)
	save()

func get_show_beta_versions() -> bool:
	return _config.get_value("general", "show_beta_versions", false)
func set_show_beta_versions(new_val: bool) -> void:
	_config.set_value("general", "show_beta_versions", new_val)
	save()

func get_show_mono_versions() -> bool:
	return _config.get_value("general", "show_mono_versions", false)
func set_show_mono_versions(new_val: bool) -> void:
	_config.set_value("general", "show_mono_versions", new_val)
	save()

func get_sort_mode() -> int:
	return _config.get_value("general", "sort_mode", 0)
func set_sort_mode(new_val: int) -> void:
	_config.set_value("general", "sort_mode", new_val)
	save()
