extends CharacterBody2D


var movement_speed = 80.0

func _physics_process(delta):
	movement()

func movement(): # function that controls movement
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov = Vector2(x_mov,y_mov)
	velocity = mov.normalized() * movement_speed
	move_and_slide() #causes character to move
