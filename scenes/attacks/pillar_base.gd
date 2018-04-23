extends Area

var player = -1
var hit = false

func body_entered(body):
	print("body entered")
	if body.is_in_group("player"):
		if body.player == player or hit:
			return
		
		hit = true
		body.health -= 2
