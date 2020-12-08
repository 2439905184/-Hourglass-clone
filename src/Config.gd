extends Node


enum SortMode {
	LAST_OPENED,
	NAME,
	VERSION,
}

signal version_settings_changed()
signal projects_sort_changed()

const CONFIG_FILE = "user://options.cfg"

var project_location : String setget set_project_location, get_project_location
var show_beta_versions : bool setget set_show_beta_versions, get_show_beta_versions
var show_mono_versions : bool setget set_show_mono_versions, get_show_mono_versions
var projects_sort : int setget set_projects_sort, get_projects_sort
var projects_sort_ascending : bool setget set_projects_sort_ascending, get_projects_sort_ascending
var git_init : bool setget set_git_init, get_git_init

var _config: ConfigFile


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
	emit_signal("version_settings_changed")
	save()


func get_show_mono_versions() -> bool:
	return _config.get_value("general", "show_mono_versions", false)

func set_show_mono_versions(new_val: bool) -> void:
	_config.set_value("general", "show_mono_versions", new_val)
	emit_signal("version_settings_changed")
	save()


func get_projects_sort() -> int:
	return _config.get_value("general", "projects_sort", 0)

func set_projects_sort(new_val: int) -> void:
	_config.set_value("general", "projects_sort", new_val)
	emit_signal("projects_sort_changed")
	save()


func get_projects_sort_ascending() -> bool:
	return _config.get_value("general", "projects_sort_ascending", false)

func set_projects_sort_ascending(new_val: bool) -> void:
	_config.set_value("general", "projects_sort_ascending", new_val)
	emit_signal("projects_sort_changed")
	save()


func get_git_init() -> bool:
	return _config.get_value("general", "git_init", true)

func set_git_init(new_val: bool) -> void:
	_config.set_value("general", "git_init", new_val)
	save()
