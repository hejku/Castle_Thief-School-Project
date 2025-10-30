extends CharacterBody2D

const speed = 30
var current_state = IDLE
var dir = Vector2.RIGHT
var start_pos
var is_roaming = true
var is_chatting = false

var player
var player_in_chat_zone = false

enum {
	IDLE,
	NEW_DIR,
	MOVE
}

func _ready():
	randomize()
	start_pos = position
	$Timer.start()  

func _physics_process(delta):
	if is_roaming and current_state == MOVE:
		move_npc(delta)

func _process(_delta):
	# Animacje
	if current_state == IDLE or current_state == NEW_DIR or is_chatting:
		$AnimatedSprite2D.play("idle")
	elif current_state == MOVE:
		if dir.x == -1:
			$AnimatedSprite2D.play("walk_w")
		elif dir.x == 1:
			$AnimatedSprite2D.play("walk_e")
		elif dir.y == -1:
			$AnimatedSprite2D.play("walk_n")
		elif dir.y == 1:
			$AnimatedSprite2D.play("walk_s")
			
	if Input.is_action_just_pressed("interact") and player_in_chat_zone and !is_chatting:
		print("Chatting with NPC")
		$"Dialogue - goblin".start()
		is_roaming = false
		is_chatting = true
		$AnimatedSprite2D.play("idle")

func choose(array):
	array.shuffle()
	return array.front()

func move_npc(_delta):
	if is_chatting:
		return
	
	velocity = dir * speed
	
	move_and_slide()
	
	if $RayCastForward.is_colliding() or is_on_wall():
		current_state = IDLE  
		dir = choose([Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN]).normalized()

func _on_chat_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		player_in_chat_zone = true

func _on_chat_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_chat_zone = false

func _on_timer_timeout() -> void:
	$Timer.wait_time = choose([0.5, 1, 1.5])
	current_state = choose([IDLE, NEW_DIR, MOVE])

func _on_dialogue__goblin_dialogue_finished() -> void:
	is_chatting = false
	is_roaming = true
