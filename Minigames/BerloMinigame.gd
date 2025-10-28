extends Control

signal minigame_finished(item)

@onready var instruction = $Label
@onready var key_label = $key_to_press
@onready var background = $Background

var all_keys = ["w", "a", "s", "d"]
var sequence_length = 8
var sequence = []
var current_index = 0
var game_active = true

@export var minigame_item_texture: Texture2D = preload("res://item/berlo.png")
@export var minigame_item_value: int = 200
@export var minigame_id := "wasd_minigame"  # Unique ID for this minigame

func _ready() -> void:
	# Check if minigame was already completed
	if _is_minigame_completed():
		game_active = false
		# Hide all UI elements
		background.visible = false
		key_label.visible = false
		
		# Show message and close immediately
		instruction.text = "Minigra już ukończona!"
		instruction.modulate = Color(1, 0.5, 0)
		await get_tree().create_timer(1.5).timeout
		emit_signal("minigame_finished", null)
		return

	sequence.clear()
	for i in range(sequence_length):
		sequence.append(all_keys[randi() % all_keys.size()])

	# Move the whole UI a bit lower
	key_label.anchor_left = 0.5
	key_label.anchor_top = 0.5
	key_label.anchor_right = 0.5
	key_label.anchor_bottom = 0.5
	key_label.offset_left = -key_label.size.x / 2
	key_label.offset_top = 150  # lower center

	instruction.anchor_left = 0.5
	instruction.anchor_top = 0.5
	instruction.anchor_right = 0.5
	instruction.anchor_bottom = 0.5
	instruction.offset_left = -instruction.size.x / 2
	instruction.offset_top = 220  # appears below the key label

	if background:
		background.color = Color(0, 0, 0, 0.6)
		background.position = Vector2.ZERO
		background.size = get_viewport_rect().size

	_update_key_label()

func _is_minigame_completed() -> bool:
	var global_inventory = get_node_or_null("/root/GlobalInventory")
	if global_inventory and global_inventory.has_method("is_minigame_completed"):
		return global_inventory.is_minigame_completed(minigame_id)
	return false

func _mark_minigame_completed():
	var global_inventory = get_node_or_null("/root/GlobalInventory")
	if global_inventory and global_inventory.has_method("mark_minigame_completed"):
		global_inventory.mark_minigame_completed(minigame_id)

func _process(_delta):
	if not game_active:
		return
		
	if current_index >= sequence.size():
		_success()
		return
		
	var expected = sequence[current_index]
	if _key_pressed(expected):
		current_index += 1
		_update_key_label()
	elif _any_key_pressed():
		_fail_minigame()
		
func _update_key_label():
	if current_index < sequence.size():
		key_label.text = "Naciśnij: " + sequence[current_index].to_upper()
	else:
		key_label.text = "Gotowe!"
		
func _key_pressed(key: String) -> bool:
	match key:
		"w": return Input.is_action_just_pressed("up")
		"a": return Input.is_action_just_pressed("left")
		"s": return Input.is_action_just_pressed("down")
		"d": return Input.is_action_just_pressed("right")
		"up": return Input.is_action_just_pressed("up")
		"down": return Input.is_action_just_pressed("down")
		"left": return Input.is_action_just_pressed("left")
		"right": return Input.is_action_just_pressed("right")
		_: return false
		
func _any_key_pressed() -> bool:
	for k in all_keys:
		if _key_pressed(k):
			return true
	return false
	
	
func _fail_minigame() -> void:
	game_active = false
	instruction.text = "Przegrałeś!"
	instruction.modulate = Color(1, 0, 0)
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://UI/lose_screen.tscn")
	
func _success() -> void:
	game_active = false
	instruction.text = "Udało się! "
	instruction.modulate = Color(0, 1, 0)
	
	await get_tree().create_timer(1.5).timeout
	
	_mark_minigame_completed()  # Mark as completed
	
	var item = {
		"texture": minigame_item_texture,
		"value": 1000,
		"name": "Throne Item",
		"type": "throne"
	}
	emit_signal("minigame_finished", item)
