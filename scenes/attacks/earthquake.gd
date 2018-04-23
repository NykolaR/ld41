extends Spatial

var player = -1 setget set_player

func set_player(new_player):
	for child in $pillars_1.get_children():
		child.player = new_player