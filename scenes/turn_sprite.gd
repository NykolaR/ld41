tool
extends Sprite

enum PLAYER {ONE, TWO, START}

export (PLAYER) var turn = 2 setget set_turn
const rotations = [0, PI, PI/2]

func set_turn(new_turn):
	new_turn = clamp(new_turn, 0, 2)
	if turn == new_turn:
		return
	
	turn = new_turn
	
	$tween.interpolate_property(self, "rotation", rotation, rotations[turn], 1.5, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	$tween.start()