extends Node


signal project_added(project_id)
signal project_removed(project_id)
signal project_changed(project_id)


var _projects_store : ConfigFile


const PROJECTS_STORE = "user://projects.cfg"


func open_project(id: String) -> int:
	update_project_last_opened(id)
	var version = get_project_version(id)
	return Versions.launch(version, [
		"--editor",
		get_project_directory(id).plus_file("/project.godot")
	])

func run_project(id: String, scene: String) -> int:
	var version = get_project_version(id)
	return Versions.launch(version, [
		"--path", get_project_directory(id),
		scene
	])

func get_projects() -> PoolStringArray:
	return _projects_store.get_sections()

func set_project_version(id: String, version: String) -> void:
	_projects_store.set_value(id, "version", version)
	emit_signal("project_changed", id)
	_save()

func get_project_version(id: String) -> String:
	return _projects_store.get_value(id, "version")

func set_project_directory(id: String, directory: String) -> void:
	_projects_store.set_value(id, "directory", directory)
	emit_signal("project_changed", id)
	_save()

func get_project_directory(id: String) -> String:
	return _projects_store.get_value(id, "directory")

func set_project_favorite(id: String, favorite: bool) -> void:
	_projects_store.set_value(id, "favorite", favorite)
	emit_signal("project_changed", id)
	_save()

func get_project_favorite(id: String) -> bool:
	return _projects_store.get_value(id, "favorite", false)

func update_project_last_opened(id: String) -> void:
	_projects_store.set_value(id, "last_opened", OS.get_unix_time())
	emit_signal("project_changed", id)
	_save()

func get_project_last_opened(id: String) -> int:
	return _projects_store.get_value(id, "last_opened")

func get_project_name(id: String) -> String:
	var cfg := ConfigFile.new()
	cfg.load(get_project_directory(id).plus_file("project.godot"))
	return cfg.get_value("application", "config/name")

func create_project(path: String, version: String) -> String:
	var id := Utils.uuid()
	set_project_directory(id, path)
	set_project_version(id, version)
	update_project_last_opened(id)
	_save()
	emit_signal("project_added", id)
	return id

func remove_project(id: String) -> void:
	_projects_store.erase_section(id)
	_save()
	emit_signal("project_removed", id)

func _ready() -> void:
	_projects_store = ConfigFile.new()
	_projects_store.load(PROJECTS_STORE)

func _get_project_value(id: String, key: String) -> String:
	return _projects_store.get_value(id, key)

func _save() -> void:
	_projects_store.save(PROJECTS_STORE)
