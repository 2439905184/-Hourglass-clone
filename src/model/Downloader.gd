extends HTTPRequest
class_name Downloader

const MIRROR = "https://downloads.tuxfamily.org/godotengine/"

var _version : String
var _url : String

func _init(version: String) -> void:
	_version = version
	_url = MIRROR + Versions.get_download_url(version)
	download_file = Versions.get_directory(version).plus_file("download.zip")

	connect("request_completed", self, "_on_request_completed")

func download() -> void:
	Versions.active_downloads += 1

	var dir := Directory.new()
	dir.make_dir_recursive(Versions.get_directory(_version))

	print("Downloading ", _url)
	request(_url)

func _process(delta: float) -> void:
	Versions.emit_signal("download_progress", _version, get_downloaded_bytes(), get_body_size())

func _on_request_completed(result: int, response: int, headers, body) -> void:
	if result != RESULT_SUCCESS:
		push_error("Download failed! Could not connect.")
		push_error("Request URL: " + _url)
		push_error("Connection error: " + str(result) + " (see https://docs.godotengine.org/en/3.1/classes/class_httprequest.html#enumerations)")
		_failed()
		return

	if response != 200:
		push_error("Download failed! HTTP status code " + str(response))
		push_error("Request URL: " + _url)
		_failed()
		return

	_extract_godot()

func _extract_godot() -> void:
	# open the zip file
	var unzip = ZipReader.new()
	unzip.open(download_file)
	var files = unzip.get_files()

	# figure out where all the needed files are
	var exec_file : String
	var godot_sharp := []
	var macos_files := []
	var prefix
	if files.size() == 1:
		exec_file = files[0]
		prefix = ""
	else:
		for file in files:
			if file.ends_with(".app/"):
				continue
			prefix = _str_prefix(prefix, file)
		for i in range(files.size()):
			var file = files[i].trim_prefix(prefix)
			files[i] = file

		if OS.get_name() == "OSX":
			# Treat macOS as a special case due to its app bundle structure
			exec_file = "MacOS/Godot"
			for file in files:
				if file == exec_file: continue
				if file.ends_with(".app/"): continue
				macos_files.append(file)
		else:
			for file in files:
				if file.begins_with("GodotSharp/"):
					godot_sharp.append(file)
				else:
					if exec_file:
						push_error("Error! Can't tell which file is the Godot executable")
						_failed()
						return
					exec_file = file

	if not exec_file:
		push_error("Error! Can't find Godot executable in zip file")
		_failed()
		return

	# if there are any files in GodotSharp/ extract them
	var dest_dir : String = Versions.get_directory(_version)
	for filename in godot_sharp + macos_files:
		if filename.find("..") != -1:
			push_error("DANGER! POTENTIAL MALICIOUS DOWNLOAD DETECTED. A file in the zip archive contains `..` which can be used to overwrite files outside the destination! Aborting.")
			push_error(filename)
			_failed()
			return

		var filepath := dest_dir.plus_file(filename)

		var dir := Directory.new()
		dir.make_dir_recursive(filepath.get_base_dir())

		var file := File.new()
		if file.open(filepath, File.WRITE) == OK:
			var data = unzip.read_file(prefix.plus_file(filename))
			file.store_buffer(data)
			file.close()

	# extract the godot executable
	var exec_path = Versions.get_executable(_version)
	var godot : PoolByteArray = unzip.read_file(prefix.plus_file(exec_file))
	var out = File.new()
	out.open(exec_path, File.WRITE)
	out.store_buffer(godot)
	out.close()

	var manifest := ConfigFile.new()
	manifest.set_value("files", "GodotSharp", godot_sharp)
	if OS.get_name() == "OSX":
		manifest.set_value("files", "macOS", macos_files)
	manifest.save(dest_dir.plus_file("manifest.cfg"))

	# make the file executable on *nix systems
	if OS.get_name() == "X11" or OS.get_name() == "OSX":
		OS.execute("chmod", ["+x", exec_path], true)

	# remove download.zip
	var directory := Directory.new()
	directory.remove(download_file)

	Versions.emit_signal("version_installed", _version)
	Versions.active_downloads -= 1
	queue_free()

func _failed() -> void:
	Versions.emit_signal("install_failed", _version)
	Versions.active_downloads -= 1
	queue_free()

# Returns the longest substring that both strings start with.
# Will just return b if a is null
func _str_prefix(a, b: String) -> String:
	if a == null: return b

	var result := ""
	for i in range(a.length()):
		if b.length() < i: break
		if b[i] != a[i]: break
		result += a[i]
	return result
