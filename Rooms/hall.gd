extends Node2D

@onready var player = $Player
@onready var exit_area = $ExitArea
@onready var exit_label = $ExitArea/RichTextLabel

var player_in_exit_zone: bool = false

func _ready() -> void:
	var timer_ui = preload("res://UI/TimerUI.tscn").instantiate()
	add_child(timer_ui)
	var spawn_node: Node2D = null
	if GameState.last_door != "":
		var path = "SpawnPoint_" + GameState.last_door
		if has_node(path):
			spawn_node = get_node(path)
		else:
			push_warning("Nie znaleziono spawnpointa: " + path)
	
	if spawn_node:
		player.global_position = spawn_node.global_position
	else:
		var start = get_node_or_null("StartPosition")
		if start:
			player.global_position = start.global_position
		else:
			push_error("Brakuje StartPosition w holu!")

	# hide label initially
	exit_label.visible = false

	# connect area signals
	exit_area.body_entered.connect(_on_exit_area_entered)
	exit_area.body_exited.connect(_on_exit_area_exited)


func _process(_delta: float) -> void:
	if player_in_exit_zone and Input.is_action_just_pressed("interact"):
		_leave_castle()


func _on_exit_area_entered(body: Node) -> void:
	if body == player:
		exit_label.visible = true
		player_in_exit_zone = true


func _on_exit_area_exited(body: Node) -> void:
	if body == player:
		exit_label.visible = false
		player_in_exit_zone = false


func _leave_castle() -> void:
	print("Leaving the castle...")
	get_tree().change_scene_to_file("res://UI/win_screen.tscn")
