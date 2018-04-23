extends Node

# resolutions
# 640x360 nHD X3
# 960x540 qHD X2
# 1280x720 HD X1.5
# 1920x1080 Full HD X1
# 3840x2160 4K X0.5

enum RESOLUTIONS {nHD, qHD, HD, fHD, FK}

const reso_options = [
{"name":"nHD", "value":Vector2(640, 360), "scale":3},
{"name":"qHD", "value":Vector2(960, 540), "scale":2},
{"name":"HD", "value":Vector2(1280, 720), "scale":1.5},
{"name":"Full HD", "value":Vector2(1920, 1080), "scale":1},
{"name":"4K", "value":Vector2(3840, 2160), "scale":0.5}
]

var resolution = reso_options[fHD]
var GI_PROBE = false

func _ready():
	randomize()
	randomize()
	randomize()