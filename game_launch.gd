extends Node2D

var menu = true
const game_base = preload("res://scenes/match_handler.tscn")

func play_pressed():
	print("pressed")
	if not menu:
		return
	
	menu = false
	
	$animation.play("fade_out")
	yield($animation, "animation_finished")
	
	$gui.hide()
	
	for child in $game_container.get_children():
		$game_container.remove_child(child)
	
	var new_game = game_base.instance()
	
	$game_container.add_child(new_game)
	
	$animation.play("fade_in")

func match_over():
	$animation.play("fade_out")
	yield($animation, "animation_finished")
	
	for child in $game_container.get_children():
		$game_container.remove_child(child)
	
	$gui.show()
	menu = true
	
	$animation.play("fade_in")

func exit_pressed():
	get_tree().quit()
