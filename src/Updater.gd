# Updater.gd -- Check for updates
#
# This Autoload class checks for updates, both for Hourglass itself and the
# version definition file (versions.cfg). The latest version of versions.cfg
# can be downloaded from the source code on GitLab, so you don't have to update
# Hourglass to download the latest Godot version.
#
# First, Updater downloads info.cfg, a small file containing the latest
# version of Hourglass and a number indicating the latest change to
# versions.cfg. If there's a new versions.cfg, it's automatically downloaded
# and applied. If the latest Hourglass version is different than the one in the
# local info.cfg, an update indicator is shown in the UI via the update_found
# signal.
#
# Updating versions.cfg
# ======================
# To update versions.cfg for a new Godot version:
# 1. Edit data/versions.cfg and add a section at the top for the new version.
#    You can probably copy/paste the previous version and just change the
#    URLs; they *usually* don't change.
# 2. Run scripts/check_versions.py. This script will verify that every URL
#    in versions.cfg returns HTTP 200 OK.
# 3. Open data/info.cfg and increment the versions_cfg number.
# 4. Commit changes and push to GitLab. No Hourglass release is necessary;
#    the new version definitions will be downloaded the next time users open
#    Hourglass.

extends HTTPRequest


signal update_found(version)


const INFO = "https://gitlab.com/jwestman/hourglass/raw/master/data/info.cfg"
const VERSIONS = "https://gitlab.com/jwestman/hourglass/raw/master/data/versions.cfg"

var current_version: String
var newest_version: String


func _ready() -> void:
	var err := OK

	if Config.disable_update_check:
		print("Update checking is disabled.")
		return

	# Get current build info from info.cfg
	var build = ConfigFile.new()
	build.load("res://data/info.cfg")
	current_version = build.get_value("general", "version")

	# Get the latest info.cfg file from GitLab
	print("Checking for updates...")
	request(INFO)
	var response = yield(self, "request_completed")

	var result: int = response[0]
	var status: int = response[1]
	var body: PoolByteArray = response[3]

	if result != RESULT_SUCCESS or status != 200:
		printerr("Failed to download info.cfg")
		return

	var info: = ConfigFile.new()
	err = info.parse(body.get_string_from_utf8())
	if err != OK:
		printerr("Failed to parse info.cfg")
		return

	# Check for Hourglass updates
	newest_version = info.get_value("general", "version")
	if newest_version != current_version:
		print("Update found: ", newest_version)
		emit_signal("update_found", newest_version)

	# Check for versions.cfg updates
	var new_update = info.get_value("general", "versions_cfg")
	if new_update > Config.versions_update:
		update_versions(new_update)

	print("Update check done.")


func update_versions(new_update: int) -> void:
	var err := OK

	# Download latest versions.cfg from GitLab
	print("Downloading new versions.cfg...")
	request(VERSIONS)
	var response = yield(self, "request_completed")

	var result: int = response[0]
	var status: int = response[1]
	var body: PoolByteArray = response[3]

	if result != RESULT_SUCCESS or status != 200:
		printerr("Failed to download versions.cfg")
		return

	var versions := ConfigFile.new()
	err = versions.parse(body.get_string_from_utf8())
	if err != OK:
		printerr("Failed to parse versions.cfg")
		return

	Versions.merge_versions(versions)
	Config.versions_update = new_update

	print("New versions.cfg applied.")
