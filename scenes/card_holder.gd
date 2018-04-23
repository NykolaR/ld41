tool
extends Spatial

enum CARDS {LEFT, CENTER, RIGHT}
const ROTATIONS = {LEFT:deg2rad(-15), CENTER:0, RIGHT:deg2rad(15)}

export (CARDS) var selected = 1 setget set_selected

func set_selected(new_selected):
	new_selected = clamp(new_selected, LEFT, RIGHT)
	
	if selected == new_selected:
		return
	
	selected = new_selected
	
	$tween.interpolate_property($rotater, "rotation:y", $rotater.rotation.y, ROTATIONS[selected], 0.6, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$tween.start()

func get_selected():
	if $rotater.get_child(selected).get_child_count() > 0:
		return $rotater.get_child(selected).get_child($rotater.get_child(selected).get_child_count() - 1)
	
	for i in range(3):
		if $rotater.get_child(i).get_child_count() > 0:
			return $rotater.get_child(i).get_child($rotater.get_child(i).get_child_count() - 1)
	
	return null

func get_card_count():
	var count = 0
	for i in range(3):
		var has_child = false
		
		if $rotater.get_child(i).get_child_count() > 0:
			for j in range($rotater.get_child(i).get_child_count()):
				if not $rotater.get_child(i).get_child(j).get_node("AnimationPlayer").is_playing():
					has_child = true
					break
				elif $rotater.get_child(i).get_child(j).get_node("AnimationPlayer").current_animation == "draw":
					has_child = true
					break
			
		if has_child:
			count += 1
	
	return count

func draw(index, card):
	if index > 2:# or $rotater.get_child(index).get_child_count() > 0:
		print("Draw failed")
		return
	
	$rotater.get_child(index).add_child(card)
	
	card.get_node("AnimationPlayer").play("draw")

func auto_draw(card):
	$rotater.get_child(selected).add_child(card)
	
	card.get_node("AnimationPlayer").play("draw")