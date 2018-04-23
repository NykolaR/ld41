extends Spatial

var turn = 0
var match_over = false
const turns = ["p1/player_1", "p2/player_2"]

func _ready():
	if randf() > 0.5:
		turn = 1
	
	flip_first_turn()
	
	if globals.GI_PROBE:
		$GIProbe.show()

func flip_turn():
	if match_over:
		return
	
	var old_turn = turn
	if turn == 0:
		if $players/p2/player_2.get_card_count() > 0:
			turn = 1
	else:
		if $players/p1/player_1.get_card_count() > 0:
			turn = 0
	
	$players/p1/player_1.end_turn(old_turn)
	$players/p2/player_2.end_turn(old_turn)
	
	if $players/p2/player_2.get_card_count() <= 0 and $players/p1/player_1.get_card_count() <= 0:
		player_won(-1)
		return
	
	$players.set_turn(turns[turn], turns[old_turn])
	$hud/turn.turn = turn
	$hud/timer_animation.play("countdown")

func flip_first_turn():
	var old_turn = turn
	if turn == 0:
		turn = 1
		$players/p1/player_1.turn = false
		$players/p2/player_2.turn = true
	else:
		turn = 0
		$players/p1/player_1.turn = true
		$players/p2/player_2.turn = false
	
	$hud/turn.turn = turn
	$hud/timer_animation.play("countdown")

func player_died(which_player):
	if which_player == 0:
		player_won(1)
	if which_player == 1:
		player_won(0)

func player_won(player):
	match_over = true
	#get_tree().call_group("game_launch", "match_over")
	if player == -1:
		$victory/end_screen/draw_game.show()
	if player == 0:
		$victory/end_screen/player_1_won.show()
	if player == 1:
		$victory/end_screen/player_2_won.show()
	
	$animation.play("victory")

func end_game():
	get_tree().call_group("game_launch", "match_over")