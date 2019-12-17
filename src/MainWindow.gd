extends VBoxContainer

func show_version(version_code: String) -> void:
	$TabContainer/Versions.select_version(version_code)
	$TabContainer.current_tab = 1
