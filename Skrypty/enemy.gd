extends CharacterBody2D

@export var speed: float = 30
@export var patrol_points: Array[Vector2] = []
@export var lose_screen_scene: PackedScene = preload("res://UI/lose_screen.tscn")

var player_chase: bool = false
var player: Node2D = null
var current_state: int = 0  
var is_chatting: bool = false
var current_patrol_index: int = 0

func _ready() -> void:
	if patrol_points.size() == 0:
		push_warning("Brak punktów patrolowych!")

	if has_node("Hitbox"):
		var hitbox = $Hitbox
		hitbox.collision_layer = 0
		hitbox.collision_mask = 1 << 0  

func _physics_process(_delta: float) -> void:
	if is_chatting:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var dir := Vector2.ZERO

	if player_chase and player and _player_has_items():
		current_state = 2
		dir = (player.global_position - global_position).normalized()
	else:
		current_state = 1
		dir = _patrol()
		player_chase = false 
		
	if $RayCastForward.is_colliding():
		var normal = $RayCastForward.get_collision_normal()
		dir = dir.slide(normal)
		
		if dir.length() < 0.1:
			dir = Vector2(randf() - 0.5, randf() - 0.5).normalized()

	velocity = dir * speed
	move_and_slide()

	_update_animation(dir)

func _player_has_items() -> bool:
	var global_inventory = get_node_or_null("/root/GlobalInventory")
	if global_inventory and global_inventory.has_method("get_items"):
		var inventory = global_inventory.get_items()
		return inventory.size() > 0
	return false

func _patrol() -> Vector2:
	if patrol_points.size() == 0:
		return Vector2.ZERO

	var target = patrol_points[current_patrol_index]
	var dir = (target - global_position).normalized()

	if global_position.distance_to(target) < 15.0:
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()

	return dir

func _update_animation(dir: Vector2) -> void:
	if current_state == 0 or current_state == 1:
		if velocity.length() < 5:
			$AnimatedSprite2D.play("idle")
		else:
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
	elif current_state == 2 and !is_chatting:
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

func _on_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and _player_has_items():
		player = body
		player_chase = true

func _on_detection_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		player_chase = false

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and _player_has_items():
		player_chase = false
		is_chatting = true
		_show_lose_screen()

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		player_chase = false

func _show_lose_screen() -> void:
	if not lose_screen_scene:
		push_warning("Brak przypisanej sceny lose screen!")
		return

	call_deferred("_deferred_change_scene")

func _deferred_change_scene():
	get_tree().change_scene_to_file("res://UI/lose_screen.tscn")
