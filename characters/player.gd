extends CharacterBody2D


var movement_speed = 80.0

func _physics_process(delta): #delta is 1 sec/framerate, keeps movement consistent at any framerate
	movement()

func movement(): #function that controls movement
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left") #If "right" is pressed, will move right, if "left" is pressed, will move left. either a 1 or 0
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up") #If "up" is pressed, will move up, if "down" is pressed, will move down. either a 1 or 0
	var mov = Vector2(x_mov,y_mov) #points on the grid
	velocity = mov.normalized() * movement_speed #velocity * mov with normalized included to make diagonal movement and linear movement the same
	move_and_slide() #causes character to move, includes Delta in calculation
