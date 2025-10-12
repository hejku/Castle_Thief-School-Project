extends CharacterBody2D

# --- Movement speeds ---
const SPEED_PATROL: float = 80.0
const SPEED_CHASE: float = 140.0

# --- State machine ---
enum State { PATROL, CHASE }
var state: State = State.PATROL

# --- Path following ---
@onready var path: Path2D = $Path2D
var path_follow: PathFollow2D
var path_t: float = 0.0

# --- Detection / player ---
@export var sight_range: float = 200.0
var player: Node2D

# --- Dialogue popup ---
@export var dialogue_popup_scene: PackedScene = preload("res://one.tscn")
var dialogue_popup: Control

func _ready() -> void:
	# Ensure the path has a valid curve before adding follower
	if not path.curve:
		push_error("Path2D has no curve assigned!")
		return
	
	# Add a PathFollow2D node to move along the curve
	path_follow = PathFollow2D.new()
	path.add_child(path_follow)

	# Try to find player automatically (assuming group "player")
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_warning("No player found in group 'player'. Please add the player to this group.")
	
	# Connect hitbox signal (make sure you have an Area2D named 'Hitbox')
	if has_node("Hitbox"):
		$Hitbox.body_entered.connect(_on_Hitbox_body_entered)
	else:
		push_warning("Enemy has no Hitbox node!")

func _physics_process(delta: float) -> void:
	if player == null:
		return
	
	match state:
		State.PATROL:
			_patrol(delta)
			_check_player_sight()
		State.CHASE:
			_chase_player(delta)
			_check_lost_player()

# --- PATROL MOVEMENT ---
func _patrol(delta: float) -> void:
	var path_length: float = path.curve.get_baked_length()
	if path_length == 0:
		return
	
	var distance_along_path: float = path_t * path_length
	distance_along_path += SPEED_PATROL * delta
	
	if distance_along_path > path_length:
		distance_along_path = 0.0
	
	path_t = distance_along_path / path_length
	
	var target_pos: Vector2 = path.curve.sample_baked(distance_along_path)
	var direction: Vector2 = (target_pos - global_position).normalized()
	velocity = direction * SPEED_PATROL
	move_and_slide()

# --- PLAYER DETECTION ---
func _check_player_sight() -> void:
	var dist: float = global_position.distance_to(player.global_position)
	if dist <= sight_range and _has_line_of_sight():
		state = State.CHASE

func _has_line_of_sight() -> bool:
	var space_state := get_world_2d().direct_space_state
	var ray_params := PhysicsRayQueryParameters2D.create(global_position, player.global_position)
	ray_params.exclude = [self]
	
	var result := space_state.intersect_ray(ray_params)
	if result.is_empty():
		return true
	if result.collider == player:
		return true
	return false

# --- CHASE MOVEMENT ---
func _chase_player(_delta: float) -> void:
	var direction: Vector2 = (player.global_position - global_position).normalized()
	velocity = direction * SPEED_CHASE
	move_and_slide()

func _check_lost_player() -> void:
	var dist: float = global_position.distance_to(player.global_position)
	if dist > sight_range * 1.5:
		state = State.PATROL

# --- DIALOGUE ---
func _on_Hitbox_body_entered(body: Node) -> void:
	if body == player:
		_show_dialogue()

func _show_dialogue() -> void:
	if dialogue_popup and dialogue_popup.is_inside_tree():
		return
	
	dialogue_popup = dialogue_popup_scene.instantiate()
	get_tree().root.add_child(dialogue_popup)
	
	# Optional: place popup near player or center of screen
	if dialogue_popup.has_method("show_message"):
		dialogue_popup.call("show_message", "You have encountered a hostile NPC!")
