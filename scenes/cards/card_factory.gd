extends Node

func get_card():
	return get_child(randi() % get_child_count()).duplicate()