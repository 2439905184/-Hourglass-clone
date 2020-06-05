extends Panel

onready var _side_panel := $VBoxContainer/HBoxContainer/SidePanel

onready var _tabs := {
	"projects": $VBoxContainer/HBoxContainer/Content/Projects,
	"versions": $VBoxContainer/HBoxContainer/Content/Versions
}

func _ready() -> void:
	_on_SidePanel_tab_changed(_side_panel.current_tab)

func _on_SidePanel_tab_changed(tab) -> void:

	for tab in _tabs.values():
		tab.hide()

	match tab:

		SidePanel.TABS.PROJECTS:
			_tabs.projects.show()

		SidePanel.TABS.VERSIONS:
			_tabs.versions.show()
