extends PanelContainer
class_name SidePanel

signal tab_changed(tab)

enum TABS { PROJECTS, VERSIONS, TEMPLATES }

var current_tab = TABS.PROJECTS setget ,_get_current_tab

onready var _top_button := $VBoxContainer/TopButton

onready var _open_button := $VBoxContainer/Buttons/Open
onready var _import_button := $VBoxContainer/Buttons/Import
onready var _scan_button := $VBoxContainer/Buttons/Scan
onready var _show_files_button := $VBoxContainer/Buttons/ShowFiles


func _get_current_tab() -> int:
	return current_tab


func _on_Projects_pressed() -> void:
	current_tab = TABS.PROJECTS
	emit_signal("tab_changed", current_tab)


func _on_Versions_pressed() -> void:
	current_tab = TABS.VERSIONS
	emit_signal("tab_changed", current_tab)


func _on_Templates_pressed() -> void:
	current_tab = TABS.TEMPLATES
	emit_signal("tab_changed", current_tab)
