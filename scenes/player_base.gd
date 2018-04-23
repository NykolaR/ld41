extends KinematicBody
# First person character controller good luck me RIP

enum PLAYERS {ONE, TWO}

export (PLAYERS) var player = 0

export (float, 1, 100) var speed = 10
export (float, 1, 100) var jump_height = 10

export (float, 0, 100) var sensitivity = 5

var health = 5 setget set_health

var turn = true

var cards = []

onready var card_holder = $cards/holder/card_holder
onready var health_container = $hud/health_container/health

const heart_image = preload("res://scenes/heart.tscn")
const shield_node = preload("res://scenes/base_scenes/shield_base.tscn")
const fireball_node = preload("res://scenes/attacks/fireball.tscn")
const earthquake_node = preload("res://scenes/attacks/earthquake.tscn")

const DEADZONE = 0.07
const MAX_VERT = 1.4
const MOVEMENT_SPEED = 2
const FIREBALL_FORCE = 15

signal card_played
signal player_died(which_player)

func _ready():
	if player == ONE:
		$camera.global_rotate(Vector3(0, 1, 0), PI)
		$cards.rotation.y = $camera.rotation.y
	
	$hud.rect_scale = Vector2(1.0/globals.resolution.scale, 1.0/globals.resolution.scale)
	
	for i in range(20):
		cards.append(card_factory.get_card())
	
	for i in range(3):
		card_holder.draw(i, cards.pop_back())

func get_card_count():
	return cards.size() + card_holder.get_card_count()

func _input(event):
	if event.is_action_pressed(str(player) + "_left_bumper"):
		$cards/holder/card_holder.selected -= 1
	if event.is_action_pressed(str(player) + "_right_bumper"):
		$cards/holder/card_holder.selected += 1
	if event.is_action_pressed(str(player) + "_shoot"):
		#play_card()
		if not turn:
			return
		
		var selected = card_holder.get_selected()
		if not selected == null:
			if selected.used:
				return
			
			emit_signal("card_played")

func _physics_process(delta):
	if health_container.get_child_count() == 0:
		player_dead()
		return
	
	var inputs = _handle_input()
	
	$camera/camera.rotate_object_local(Vector3(1, 0, 0), inputs.R_VERTICAL * sensitivity * -delta)
	$camera/camera.rotation.x = clamp($camera/camera.rotation.x, -MAX_VERT, MAX_VERT)
	$camera.global_rotate(Vector3(0, 1, 0), inputs.R_HORIZONTAL * sensitivity * -delta)
	
	$cards.rotation.y = $camera.rotation.y
	
	var movement = Vector3(inputs.L_HORIZONTAL, 0, inputs.L_VERTICAL)
	movement = movement.rotated(Vector3(0, 1, 0), $camera.rotation.y)
	movement *= MOVEMENT_SPEED
	
	move_and_slide(movement)

func _handle_input():
	var inputs = {"L_HORIZONTAL":0, "L_VERTICAL":0, "R_HORIZONTAL":0, "R_VERTICAL":0, "L_BUMP":false, "R_BUMP":false}
	
	inputs.L_HORIZONTAL = clamp(abs(Input.get_joy_axis(player, JOY_ANALOG_LX)) - DEADZONE, 0, 1) * sign(Input.get_joy_axis(player, JOY_ANALOG_LX))
	inputs.L_VERTICAL = clamp(abs(Input.get_joy_axis(player, JOY_ANALOG_LY)) - DEADZONE, 0, 1) * sign(Input.get_joy_axis(player, JOY_ANALOG_LY))
	inputs.R_HORIZONTAL = pow(clamp(abs(Input.get_joy_axis(player, JOY_ANALOG_RX)) - DEADZONE, 0, 1), 2) * sign(Input.get_joy_axis(player, JOY_ANALOG_RX))
	inputs.R_VERTICAL = pow(clamp(abs(Input.get_joy_axis(player, JOY_ANALOG_RY)) - DEADZONE, 0, 1), 2) * sign(Input.get_joy_axis(player, JOY_ANALOG_RY))
	
	return inputs

func player_dead():
	set_physics_process(false)
	set_process_input(false)
	emit_signal("player_died", player)

func set_health(new_health):
	if health > clamp(new_health, 0, 5):
		$hurt.play()
	
	health = clamp(new_health, 0, 5)
	
	if health <= 0:
		for child in health_container.get_children():
			child.get_node("animation").play("despawn")
		
		player_dead()
		#kill player
		return
	else:
		while health_container.get_child_count() > health:
			var next = 0
			var dead = health_container.get_child(wrapi(health_container.get_child_count()/2, 0, 5))
			
			while dead.get_node("animation").is_playing() == true and next < 6:
				next += 1
				var val = next
				if next % 2:
					val -= 1
					val *= -1
				dead = health_container.get_child(wrapi(health_container.get_child_count()/2 + val, 0, health_container.get_child_count()))
			
			if next >= 6:
				break
			
			dead.get_node("animation").play("despawn")
			health += 1
	
	health = clamp(new_health, 0, 5)
	
	while health_container.get_child_count() < health:
		health_container.add_child(heart_image.instance())

func end_turn(player_turn):
	if not player == player_turn:
		for child in $camera/camera.get_children():
			if child.is_in_group("shield"):
				child.get_child(1).play("despawn")
	else:
		play_card()

func play_card():
	var selected = card_holder.get_selected()
	turn = false
	
	if selected == null:
		return
	
	if selected.card_type == arena_globals.HEALING:
		self.health += selected.level
		$heal.play()
	
	if selected.card_type == arena_globals.SHOT:
		$shoot.play()
		$camera/camera/guncast.enabled = true
		$camera/camera/guncast.force_raycast_update()
		if $camera/camera/guncast.is_colliding():
			var collider = $camera/camera/guncast.get_collider()
			
			if collider.is_in_group("player"):
				collider.health -= selected.level
	
	if selected.card_type == arena_globals.SHIELD:
		$shield.play()
		var new_shield = shield_node.instance()
		$camera/camera.add_child(new_shield)
		
		new_shield.get_child(1).play("spawn")
	
	if selected.card_type == arena_globals.FIRE:
		for i in range(selected.level):
			var new_fireball = fireball_node.instance()
			get_parent().get_parent().add_child(new_fireball)
			new_fireball.translation = $camera/camera/fireball_spawn.global_transform.origin
			new_fireball.set_player(player)
			new_fireball.apply_impulse(Vector3(), $camera/camera.global_transform.basis.z.normalized().rotated(Vector3(0, 1, 0), rand_range(-0.05, 0.05)) * -(FIREBALL_FORCE + rand_range(-5, 5)))
	
	if selected.card_type == arena_globals.EARTH:
		var count = 0
		if selected.level == 1:
			count = 1
		else:
			count = 3
		for i in range(count):
			var new_earth = earthquake_node.instance()
			new_earth.player = player
			get_parent().get_parent().add_child(new_earth)
			new_earth.translation = global_transform.origin
			#new_earth.rotate_y($camera/camera.rotation.y + PI)
			new_earth.rotation = $camera.rotation
			new_earth.rotate_y(PI)
			new_earth.rotate_y(rand_range(-0.5, 0.5))
			new_earth.get_node("animation").play("earthquake_1")
	
	selected.played()
	if cards.size() > 0:
		card_holder.auto_draw(cards.pop_back())