class_name VersionsUpdater
extends HTTPRequest


signal request_failed()
signal versions_updated()

const URL = "https://gitlab.com/FlyingPiMonster/hourglass/raw/master/data/versions.cfg"
const DOWNLOAD_PATH = "user://versions_update.cfg"


func _ready() -> void:
	connect("request_completed", self, "_on_request_completed")
	download_file = DOWNLOAD_PATH
	request(URL)

func _on_request_completed(result: int, response: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if result != RESULT_SUCCESS or response != 200:
		emit_signal("request_failed")
	else:
		emit_signal("versions_updated")
	queue_free()
