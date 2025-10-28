extends CharacterBody2D

@export var speed = 75
var current_state = 0 
var dir = Vector2.ZERO

func get_input():
	dir = Input.get_vector("left", "right", "up", "down")
	if dir != Vector2.ZERO:
		current_state = 2  
		dir = dir.normalized()
	else:
		current_state = 0  
		
	velocity = dir * speed
	
func _physics_process(_delta):
	get_input()
	move_and_slide()
	
func _process(_delta):
	if current_state == 0:
		$AnimatedSprite2D.play("idle")
	elif current_state == 2:
		if abs(dir.x) > abs(dir.y):
			if dir.x < 0:
				$AnimatedSprite2D.play("walk_w")
			else:
				$AnimatedSprite2D.play("walk_e")
		else:
			if dir.y < 0:
				$AnimatedSprite2D.play("walk_n")
			else:
				$AnimatedSprite2D.play("walk_s")
				
