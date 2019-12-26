extends Control

func show_version(version_code: String) -> void:
	$TabContainer/Versions.select_version(version_code)
	$TabContainer.current_tab = 1

func _ready() -> void:
	var build = ConfigFile.new()
	build.load("res://data/build.cfg")
	$HBox/Version.text = "v" + build.get_value("build", "version")

func _on_Version_pressed() -> void:
	OS.shell_open("https://gitlab.com/FlyingPiMonster/godot-version-manager")
