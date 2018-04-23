extends RigidBody

var active = true
var hit = false
var player

func set_player(new_player):
	player = new_player
	
	$animation.play("spawn")

func body_entered(body):
	if not active and hit:
		return
	
	if body.is_in_group("player"):
		if player == body.player:
			return
		
		if active:
			body.health -= 2
		else:
			body.health -= 1
		
		hit = true
	
	active = false
	$animation.play("despawn")

func kill_if_active():
	if active:
		queue_free()

func area_body_entered(body):
	if not active and hit:
		return
	
	if body.is_in_group("player"):
		if player == body.player:
			return
		
		if active:
			body.health -= 2
		else:
			body.health -= 1
		
		hit = true
	
	active = false
	
	$animation.play("despawn")