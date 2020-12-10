class_name Utils
extends Object


const GODOT_DONATE_LINK := "https://godotengine.org/donate"
const SOURCE_LINK := "https://gitlab.com/jwestman/hourglass"
const UPDATE_LINK := "https://hourglass.flyingpimonster.net"
const GLES_LINK := "https://docs.godotengine.org/en/latest/tutorials/rendering/gles2_gles3_differences.html"


# Creates a v4 UUID. See <https://en.wikipedia.org/wiki/Universally_unique_identifier#Version_4_(random)>.
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
