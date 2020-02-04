class_name Utils
extends Object


static func uuid() -> String:
	var rand := RandomNumberGenerator.new()
	rand.randomize()
	var bytes := PoolByteArray()
	for _i in range(15):
		bytes.append(rand.randi_range(0, 255))

	var tmp := ["8", "9", "a", "b"]
	tmp.shuffle()
	var res := bytes.hex_encode()
	res = res.insert(16, tmp[0]).insert(12, "4")
	res = res.insert(20, "-").insert(16, "-").insert(12, "-").insert(8, "-")
	return res

static func list_dir_recursive(path: String) -> PoolStringArray:
	var result : PoolStringArray = []
	var dir := Directory.new()

	dir.open(path)
	dir.list_dir_begin(true, false)
	var child := dir.get_next()
	while child != "":
		var child_path := path.plus_file(child)

		if dir.current_is_dir():
			result.append_array(list_dir_recursive(child_path))
		result.append(child_path)

		child = dir.get_next()

	return result
