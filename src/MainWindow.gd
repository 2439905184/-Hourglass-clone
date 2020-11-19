extends Panel


onready var side_panel := $VBoxContainer/HBoxContainer/SidePanel
onready var search_bar := $VBoxContainer/Margin/TopBar/SearchBar
onready var confirm_quit := $ConfirmQuit
onready var content := $VBoxContainer/HBoxContainer/Content
onready var projects := $VBoxContainer/HBoxContainer/Content/Projects
onready var versions := $VBoxContainer/HBoxContainer/Content/Versions
onready var templates := $VBoxContainer/HBoxContainer/Content/Templates
onready var about_dialog := $AboutDialog

onready var tabs := [
	projects, versions, templates
]

func _ready() -> void:
	_on_SidePanel_tab_changed(side_panel.current_tab)
	get_tree().set_auto_accept_quit(false)


func _notification(what: int) -> void:
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if _should_ask_before_quitting():
			confirm_quit.show_dialog()
		else:
			get_tree().quit()


func show_tab(tab: int) -> void:
	content.current_tab = tab
	side_panel.current_tab = tab
	search_bar.text = tabs[tab].search_query
	var placeholders := [
		tr("Search projects..."),
		tr("Search versions..."),
		tr("Search Asset Library...")
	]
	search_bar.placeholder_text = placeholders[tab]


func show_version(version_code: String) -> void:
	show_tab(SidePanel.TABS.VERSIONS)
	versions.select_version_by_code(version_code)


func quit() -> void:
	if !_should_ask_before_quitting():
		get_tree().quit()


func _should_ask_before_quitting() -> bool:
	return Versions.active_downloads != 0


func _on_SidePanel_tab_changed(tab) -> void:
	show_tab(tab)


func _on_SearchBar_search_changed(new_text) -> void:
	tabs[side_panel.current_tab].search_query = search_bar.text


func _on_SidePanel_action_pressed(name: String) -> void:
	match name:
		"projects.new":
			projects.create_new_project()
		"projects.import":
			projects.import_project()
		"projects.scan":
			# not implemented yet
			pass
		"versions.add":
			versions.create_custom_version()


func _on_LogoButton_pressed() -> void:
	about_dialog.show_dialog()
