extends Panel

onready var _side_panel := $VBoxContainer/HBoxContainer/SidePanel
onready var confirm_quit := $ConfirmQuit

onready var confirm_quit: ConfirmationDialog = $ConfirmQuit
onready var _tabs := {
	"projects": $VBoxContainer/HBoxContainer/Content/Projects,
	"versions": $VBoxContainer/HBoxContainer/Content/Versions
}


func _ready() -> void:
	_on_SidePanel_tab_changed(_side_panel.current_tab)
	get_tree().set_auto_accept_quit(false)


func _notification(what: int) -> void:
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if _should_ask_before_quitting():
			confirm_quit.popup_centered()
		else:
			get_tree().quit()


func show_tab(version: int) -> void:
	for tab in _tabs.values():
		tab.hide()

	match version:
		SidePanel.TABS.PROJECTS:
			_tabs.projects.show()
		SidePanel.TABS.VERSIONS:
			_tabs.versions.show()


func show_version(version_code: String) -> void:
	show_tab(SidePanel.TABS.VERSIONS)
	_tabs.versions.select_version(version_code)


func quit() -> void:
	if !_should_ask_before_quitting():
		get_tree().quit()


func _should_ask_before_quitting() -> bool:
	return Versions.active_downloads != 0


func _on_SidePanel_tab_changed(tab) -> void:
	show_tab(tab)


