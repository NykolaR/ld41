extends Spatial

enum TYPES {HEALING, SHIELD, FIRE, EARTH, SHOT}

export (TYPES) var card_type = 0
export (int, 0, 3) var level = 1

var used = false

func played():
	used = true
	get_node("AnimationPlayer").play("discard")