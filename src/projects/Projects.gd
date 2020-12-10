# Projects.gd -- Stores the project list
#
# Project details are stored in user://projects.cfg. Each project has its own
# section of the file.

extends Node


signal project_added(project_id)
signal project_removed(project_id)
signal project_changed(project_id)

const PROJECTS_STORE = "user://projects.cfg"

var _projects_store: ConfigFile


func _ready() -> void:
	_projects_store = ConfigFile.new()
	_projects_store.load(PROJECTS_STORE)


# Opens the project in the Godot editor.
func open_project(id: String) -> int:
	update_project_last_opened(id)
	var version := get_project_version(id)
	return Versions.launch(version, [
		"--editor",
		get_project_directory(id).plus_file("/project.godot")
	])


# Runs the project.
func run_project(id: String, scene: String) -> int:
	var version := get_project_version(id)
	return Versions.launch(version, [
		"--path", get_project_directory(id),
		scene
	])


# Gets a list of all project IDs.
func get_projects() -> PoolStringArray:
	return _projects_store.get_sections()


# Sets the Godot version that a project should be run with.
func set_project_version(id: String, version: String) -> void:
	_projects_store.set_value(id, "version", version)
	emit_signal("project_changed", id)
	_save()

# Gets the Godot version that a project should be run with.
func get_project_version(id: String) -> String:
	return _projects_store.get_value(id, "version")


# Sets the directory for a project.
func set_project_directory(id: String, directory: String) -> void:
	_projects_store.set_value(id, "directory", directory)
	emit_signal("project_changed", id)
	_save()

# Gets the directory for a project.
func get_project_directory(id: String) -> String:
	return _projects_store.get_value(id, "directory")


# Marks/unmarks a project as a favorite.
func set_project_favorite(id: String, favorite: bool) -> void:
	_projects_store.set_value(id, "favorite", favorite)
	emit_signal("project_changed", id)
	_save()

# Gets whether the project is marked as a favorite.
func get_project_favorite(id: String) -> bool:
	return _projects_store.get_value(id, "favorite", false)


# Sets a project's last opened time to the current time.
func update_project_last_opened(id: String) -> void:
	_projects_store.set_value(id, "last_opened", OS.get_unix_time())
	emit_signal("project_changed", id)
	_save()

# Gets the timestamp that a project was last opened in Hourglass.
func get_project_last_opened(id: String) -> int:
	return _projects_store.get_value(id, "last_opened")


# Gets the name of a project from its project.godot file.
func get_project_name(id: String) -> String:
	var cfg := ConfigFile.new()
	cfg.load(get_project_directory(id).plus_file("project.godot"))
	return cfg.get_value("application", "config/name")


# Adds a new project to the list.
# This doesn't actually create the project directory. For that, you need the
# ProjectCreator class, which will automatically call this function.
func create_project(path: String, version: String) -> String:
	var id := Utils.uuid()
	set_project_directory(id, path)
	set_project_version(id, version)
	update_project_last_opened(id)
	_save()
	emit_signal("project_added", id)
	return id


# Removes a project from the list. No files are deleted.
func remove_project(id: String) -> void:
	_projects_store.erase_section(id)
	_save()
	emit_signal("project_removed", id)


func _get_project_value(id: String, key: String) -> String:
	return _projects_store.get_value(id, key)


func _save() -> void:
	_projects_store.save(PROJECTS_STORE)
