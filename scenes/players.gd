extends Spatial

func _ready():
	$p1.size = globals.resolution.value * Vector2(0.5, 1)
	$s1.scale = Vector2(globals.resolution.scale, globals.resolution.scale)
	
	$p2.size = globals.resolution.value * Vector2(0.5, 1)
	$s2.scale = Vector2(globals.resolution.scale, globals.resolution.scale)

func _input(event):
	$p1.input(event)
	$p2.input(event)

func set_turn(turn, not_turn):
	get_node(turn).turn = true
	get_node(not_turn).turn = false