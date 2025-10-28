extends Area2D

@export var target_spawn_point: String = "HallDoor"  
@export var target_scene_path: String = "res://Rooms/Throne.tscn"
@export var spawn_position: Vector2 

@onready var prompt_label = $RichTextLabel
var player_in_area := false

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	prompt_label.visible = false

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		player_in_area = true
		print("Wciśnij E, aby wejść do pokoju.")
	if body.is_in_group("player"):
		player_in_area = true
		prompt_label.visible = true

func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		player_in_area = false
	if body.is_in_group("player"):
		player_in_area = false
		prompt_label.visible = false

func _process(_delta):
	if player_in_area and Input.is_action_just_pressed("interact"): 
		_change_scene()

func _change_scene():
	var game_state = get_node("/root/GameState")
	game_state.last_door = target_spawn_point
	game_state.last_position = spawn_position

	if target_scene_path != "":
		get_tree().change_scene_to_file(target_scene_path)
