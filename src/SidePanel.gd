extends PanelContainer
class_name SidePanel

signal tab_changed(tab)
signal action_pressed(name)

enum TABS { PROJECTS, VERSIONS, TEMPLATES }

var current_tab = TABS.PROJECTS setget set_current_tab, get_current_tab

onready var projects_button := $VBoxContainer/TabButtons/Projects
onready var versions_button := $VBoxContainer/TabButtons/Versions
onready var templates_button := $VBoxContainer/TabButtons/Templates
onready var pane_tabs := $VBoxContainer/Panes
onready var beta_versions := $VBoxContainer/Panes/Versions/BetaVersions
onready var mono_versions := $VBoxContainer/Panes/Versions/MonoVersions

onready var buttons := [
	projects_button, versions_button, templates_button
]


func _ready() -> void:
	beta_versions.pressed = Config.show_beta_versions
	mono_versions.pressed = Config.show_mono_versions


func get_current_tab() -> int:
	return current_tab


func set_current_tab(new_tab: int) -> void:
	buttons[new_tab].pressed = true
	pane_tabs.current_tab = new_tab


func _on_Projects_pressed() -> void:
	current_tab = TABS.PROJECTS
	emit_signal("tab_changed", current_tab)


func _on_Versions_pressed() -> void:
	current_tab = TABS.VERSIONS
	emit_signal("tab_changed", current_tab)


func _on_Templates_pressed() -> void:
	current_tab = TABS.TEMPLATES
	emit_signal("tab_changed", current_tab)


func _on_BetaVersions_toggled(pressed: bool) -> void:
	Config.show_beta_versions = pressed


func _on_MonoVersions_toggled(pressed: bool) -> void:
	Config.show_mono_versions = pressed


func _on_New_pressed() -> void:
	emit_signal("action_pressed", "projects.new")


func _on_Import_pressed() -> void:
	emit_signal("action_pressed", "projects.import")


func _on_Scan_pressed() -> void:
	emit_signal("action_pressed", "projects.scan")


func _on_AddCustom_pressed() -> void:
	emit_signal("action_pressed", "versions.add")
