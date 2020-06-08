extends PanelContainer
class_name SidePanel

signal tab_changed(tab)

enum TABS { PROJECTS, VERSIONS, TEMPLATES }

var current_tab = TABS.PROJECTS setget set_current_tab, get_current_tab

onready var _top_button := $VBoxContainer/TopButton

onready var _open_button := $VBoxContainer/Buttons/Open
onready var _import_button := $VBoxContainer/Buttons/Import
onready var _scan_button := $VBoxContainer/Buttons/Scan
onready var _show_files_button := $VBoxContainer/Buttons/ShowFiles
onready var projects = $VBoxContainer/TabButtons/Projects
onready var versions = $VBoxContainer/TabButtons/Versions
onready var templates = $VBoxContainer/TabButtons/Templates


func get_current_tab() -> int:
	return current_tab


func set_current_tab(new_tab: int) -> void:
	match new_tab:
		TABS.PROJECTS:
			projects.pressed = true
		TABS.VERSIONS:
			versions.pressed = true
		TABS.TEMPLATES:
			templates.pressed = true


func _on_Projects_pressed() -> void:
	current_tab = TABS.PROJECTS
	emit_signal("tab_changed", current_tab)


func _on_Versions_pressed() -> void:
	current_tab = TABS.VERSIONS
	emit_signal("tab_changed", current_tab)


func _on_Templates_pressed() -> void:
	current_tab = TABS.TEMPLATES
	emit_signal("tab_changed", current_tab)
