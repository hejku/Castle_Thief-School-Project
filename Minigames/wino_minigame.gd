extends Control

signal minigame_finished(item)

@onready var door = $Door
@onready var instruction = $Label
@onready var background = $Background

var is_dragging := false
var last_mouse_pos: Vector2
var open_progress := 0.0
var fail_threshold := 600.0
var open_target := 300.0
var game_active := true

var max_attempts := 2
var attempts_left := max_attempts

@export var minigame_item_texture: Texture2D = preload("res://CastleThiefTiles(original)/wino_gra.png")
@export var minigame_item_value: int = 250
@export var minigame_id := "door_minigame" 

func _ready() -> void:
	if _is_minigame_completed():
		game_active = false
		background.visible = false
		door.visible = false
		
		instruction.text = "Minigra już ukończona!"
		instruction.modulate = Color(1, 0.5, 0)
		await get_tree().create_timer(1.5).timeout
		emit_signal("minigame_finished", null)
		return

	size = get_viewport_rect().size
	anchor_left = 0
	anchor_top = 0
	anchor_right = 1
	anchor_bottom = 1
	position = Vector2.ZERO

	if background:
		background.color = Color(0,0,0,0.6)
		background.anchor_left = 0
		background.anchor_top = 0
		background.anchor_right = 1
		background.anchor_bottom = 1
		background.position = Vector2.ZERO

	if door:
		door.color = Color(0.4,0.25,0.1)
		door.size = Vector2(200,400)
		door.anchor_left = 0.5
		door.anchor_right = 0.5
		door.anchor_top = 0.5
		door.anchor_bottom = 0.5
		door.position = Vector2(size.x/2, size.y/2 - 250)

	if instruction:
		instruction.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		instruction.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		instruction.anchor_left = 0.5
		instruction.anchor_right = 0.5
		instruction.anchor_top = 0.9
		instruction.anchor_bottom = 0.9
		instruction.offset_left = -200
		instruction.offset_right = 200
		instruction.offset_top = -20
		instruction.offset_bottom = 20
		instruction.modulate = Color(1,1,1)
		_update_instruction_text()

	open_progress = 0.0
	is_dragging = false

func _is_minigame_completed() -> bool:
	var global_inventory = get_node_or_null("/root/GlobalInventory")
	if global_inventory and global_inventory.has_method("is_minigame_completed"):
		return global_inventory.is_minigame_completed(minigame_id)
	return false

func _mark_minigame_completed():
	var global_inventory = get_node_or_null("/root/GlobalInventory")
	if global_inventory and global_inventory.has_method("mark_minigame_completed"):
		global_inventory.mark_minigame_completed(minigame_id)

func _process(delta: float) -> void:
	if not game_active:
		return

	if is_dragging:
		var mouse = get_global_mouse_position()
		var diff = mouse.x - last_mouse_pos.x
		var safe_delta = max(delta, 0.0001)
		var speed = abs(diff) / safe_delta

		if speed > fail_threshold:
			_attempt_failed()
			return

		open_progress += diff
		open_progress = clamp(open_progress, 0.0, open_target)

		if door:
			door.position.x = (size.x / 2) + open_progress

		if open_progress >= open_target:
			_success()

		last_mouse_pos = mouse


func _input(event: InputEvent) -> void:
	if not game_active:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if door and door.get_global_rect().has_point(event.position):
				is_dragging = true
				last_mouse_pos = get_global_mouse_position()
		else:
			is_dragging = false


func _attempt_failed() -> void:
	is_dragging = false
	open_progress = 0.0
	if door:
		door.position.x = size.x / 2

	attempts_left -= 1

	if attempts_left > 0:
		_update_instruction_text("Za szybko! Spróbuj ponownie.\nPozostałe próby: %d" % attempts_left, Color(1,0.5,0))
	else:
		_fail_minigame()


func _fail_minigame() -> void:
	game_active = false
	_update_instruction_text("Przegrałeś!", Color(1,0,0))
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://UI/lose_screen.tscn")


func _success() -> void:
	game_active = false
	is_dragging = false
	_update_instruction_text("Udało się!", Color(0,1,0))
	await get_tree().create_timer(1.5).timeout

	_mark_minigame_completed()  

	var item = {
		"texture": minigame_item_texture,
		"value": 500,
		"name": "Dining Item",
		"type": "dining"
	}
	emit_signal("minigame_finished", item)


func _update_instruction_text(text: String = "", color: Color = Color(1,1,1)) -> void:
	if instruction:
		instruction.text = text if text != "" else "Przytrzymaj LPM i powoli otwórz drzwi gabloty...\nPozostałe próby: %d" % attempts_left
		instruction.modulate = color
