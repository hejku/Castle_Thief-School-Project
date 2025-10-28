extends Control

signal minigame_finished(item)

@onready var instruction = $VBoxContainer/Label
@onready var background = $Background
@onready var targets_container = $CenterContainer/HBoxContainer
@onready var timer = $Timer  # Add Timer node in scene tree

var dragging_item: Control = null
var drag_offset: Vector2 = Vector2.ZERO
var placed_count := 0
var game_active := true
var item_targets = {}
var waiting_for_start := true
var time_left := 10

@export var minigame_item_texture: Texture2D = preload("res://item/konstytucja.png")
@export var minigame_item_value: int = 15
@export var minigame_id := "drag_drop_minigame"  

func _ready() -> void:
	# Check if minigame was already completed
	if _is_minigame_completed():
		game_active = false
		background.visible = false
		targets_container.visible = false
		
		instruction.text = "Minigra już ukończona!"
		instruction.modulate = Color(1, 0.5, 0)
		await get_tree().create_timer(1.5).timeout
		emit_signal("minigame_finished", null)
		return

	await get_tree().process_frame  
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size = get_viewport_rect().size
	position = Vector2.ZERO

	background.color = Color(0, 0, 0, 0.6)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.size = get_viewport_rect().size
	background.position = Vector2.ZERO

	set_anchors_preset(Control.PRESET_FULL_RECT)

	instruction.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instruction.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# Show start screen
	_show_start_screen()

func _show_start_screen() -> void:
	waiting_for_start = true
	game_active = false
	
	if instruction:
		instruction.text = "Put the colorful items in their right places!\nClick anywhere to start"
		instruction.modulate = Color(1, 1, 1)

func _start_minigame() -> void:
	waiting_for_start = false
	game_active = true
	
	# Setup game elements
	var targets = targets_container.get_children()
	var items = []
	for child in get_children():
		if child is ColorRect and child != background and child != targets_container and child != $VBoxContainer:
			items.append(child)

	for target in targets:
		target.custom_minimum_size = Vector2(80, 80)
		target.color = Color(0, 0, 0)
		target.mouse_filter = Control.MOUSE_FILTER_IGNORE

	for i in range(len(items)):
		var item = items[i]
		var target = targets[i]
		item.custom_minimum_size = Vector2(80, 80)
		item.mouse_filter = Control.MOUSE_FILTER_STOP
		item_targets[item] = target
		item.position = Vector2(randf_range(100, 1740), randf_range(100, 900))

	# Setup timer
	if timer:
		timer.wait_time = 1.0
		timer.timeout.connect(_on_timer_timeout)
		timer.start()
	
	_update_instruction()

func _update_instruction() -> void:
	if instruction:
		instruction.text = "Przeciągnij przedmioty we właściwe miejsca!\nPozostało: %d/%d | Czas: %ds" % [placed_count, len(item_targets), int(time_left)]

func _on_timer_timeout():
	if not game_active:
		return
		
	time_left -= 1.0
	_update_instruction()
	
	if time_left <= 0:
		_fail_minigame("Czas minął!")

func _input(event: InputEvent) -> void:
	if waiting_for_start:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_start_minigame()
			return
	
	if not game_active:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			for item in item_targets.keys():
				if item.mouse_filter == Control.MOUSE_FILTER_STOP and item.get_global_rect().has_point(event.position):
					dragging_item = item
					drag_offset = item.get_global_position() - event.global_position
					break
		else:
			if dragging_item:
				_check_place(dragging_item)
				dragging_item = null

	if event is InputEventMouseMotion and dragging_item:
		dragging_item.global_position = event.global_position + drag_offset

func _check_place(item: Control) -> void:
	var target = item_targets[item]
	var item_rect = Rect2(item.global_position, item.size)
	var target_rect = Rect2(target.global_position, target.size)
	
	if item_rect.intersects(target_rect):
		item.global_position = target.global_position
		item.mouse_filter = Control.MOUSE_FILTER_IGNORE  # disables future movement
		placed_count += 1
		_update_instruction()

	if placed_count >= len(item_targets):
		_success()

func _is_minigame_completed() -> bool:
	var global_inventory = get_node_or_null("/root/GlobalInventory")
	if global_inventory and global_inventory.has_method("is_minigame_completed"):
		return global_inventory.is_minigame_completed(minigame_id)
	return false

func _mark_minigame_completed():
	var global_inventory = get_node_or_null("/root/GlobalInventory")
	if global_inventory and global_inventory.has_method("mark_minigame_completed"):
		global_inventory.mark_minigame_completed(minigame_id)

func _success() -> void:
	game_active = false
	if timer:
		timer.stop()
		
	instruction.text = "Wszystkie przedmioty na miejscu!"
	instruction.modulate = Color(0, 1, 0)
	await get_tree().create_timer(1.5).timeout

	_mark_minigame_completed()  # Mark as completed

	var item = {
		"texture": minigame_item_texture,
		"value": 250,
		"name": "Office Item",
		"type": "document"
	}
	emit_signal("minigame_finished", item)

func _fail_minigame(reason: String = "") -> void:
	game_active = false
	if timer:
		timer.stop()
		
	instruction.text = "Przegrałeś! " + reason
	instruction.modulate = Color(1, 0, 0)
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://UI/lose_screen.tscn")
