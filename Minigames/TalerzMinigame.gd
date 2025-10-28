extends Control

signal minigame_finished(item)

@onready var instruction = $Label
@onready var background = $Background
@onready var timer = $Timer  # Add Timer node in scene tree

var plates: Array[Control] = []
var dirt_layers: Array[ColorRect] = []
var current_plate_index := 0
var plates_to_clean := 5
var game_active := true
var time_left := 7
var waiting_for_start := true  

@export var minigame_item_texture: Texture2D = preload("res://item/plate.png")
@export var minigame_item_value: int = 150
@export var minigame_id := "plate_cleaning_minigame"  

func _ready() -> void:
	if _is_minigame_completed():
		game_active = false
		background.visible = false
		
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
		background.color = Color(0, 0, 0, 0.7)
		background.anchor_left = 0
		background.anchor_top = 0
		background.anchor_right = 1
		background.anchor_bottom = 1
		background.position = Vector2.ZERO
		background.size = size
		
	if instruction:
		instruction.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		instruction.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		instruction.anchor_left = 0.5
		instruction.anchor_right = 0.5
		instruction.anchor_top = 0.95
		instruction.anchor_bottom = 0.95
		instruction.offset_left = -250
		instruction.offset_right = 250
		instruction.offset_top = -30
		instruction.offset_bottom = 30
		instruction.modulate = Color(1, 1, 1)

	# Show start screen
	_show_start_screen()

func _show_start_screen() -> void:
	waiting_for_start = true
	game_active = false
	
	if instruction:
		instruction.anchor_top = 0.1  # Move to top middle
		instruction.anchor_bottom = 0.1
		instruction.text = "Clean the plates before time runs out!\nClick anywhere to start"
		instruction.modulate = Color(1, 1, 1)

func _start_minigame() -> void:
	waiting_for_start = false
	game_active = true
	
	# Reset instruction position
	if instruction:
		instruction.anchor_top = 0.95
		instruction.anchor_bottom = 0.8
		instruction.anchor_left = 0.5
		instruction.anchor_right = 0.5
		instruction.offset_left = -250
		instruction.offset_right = 250

	# Setup timer
	if timer:
		timer.wait_time = 1.0
		timer.timeout.connect(_on_timer_timeout)
		timer.start()

	# Create plates
	_create_plates()

func _input(event: InputEvent) -> void:
	if waiting_for_start:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_start_minigame()
			return
	
	if not game_active:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_check_plate_clean(event.position)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_check_plate_clean(event.position)

func _is_minigame_completed() -> bool:
	var global_inventory = get_node_or_null("/root/GlobalInventory")
	if global_inventory and global_inventory.has_method("is_minigame_completed"):
		return global_inventory.is_minigame_completed(minigame_id)
	return false

func _mark_minigame_completed():
	var global_inventory = get_node_or_null("/root/GlobalInventory")
	if global_inventory and global_inventory.has_method("mark_minigame_completed"):
		global_inventory.mark_minigame_completed(minigame_id)

func _create_plates() -> void:
	for plate in plates:
		plate.queue_free()
	plates.clear()
	dirt_layers.clear()

	for i in range(plates_to_clean):
		var plate_container = _create_single_plate(i)
		plates.append(plate_container)

	_show_plate(0)

func _create_single_plate(index: int) -> Control:
	var plate_container = Control.new()
	plate_container.name = "Plate%d" % index
	plate_container.size = Vector2(150, 150)
	plate_container.anchor_left = 0.5
	plate_container.anchor_top = 0.5
	plate_container.anchor_right = 0.5
	plate_container.anchor_bottom = 0.5
	plate_container.offset_left = -75
	plate_container.offset_top = -75

	# Plate background
	var plate = ColorRect.new()
	plate.name = "PlateBackground"
	plate.color = Color(0.579, 0.784, 0.988, 1)
	plate.size = Vector2(150, 150)

	var circle_shader = Shader.new()
	circle_shader.code = """
	shader_type canvas_item;
	void fragment() {
		vec2 center = UV - vec2(0.5);
		if(length(center) > 0.5){
			discard;
		}
	}
	"""
	plate.material = ShaderMaterial.new()
	plate.material.shader = circle_shader

	# Dirt layer
	var dirt = ColorRect.new()
	dirt.name = "DirtLayer"
	dirt.color = Color(0.4, 0.2, 0.1, 1)
	dirt.size = Vector2(150, 150)
	dirt.material = ShaderMaterial.new()
	dirt.material.shader = circle_shader

	plate_container.add_child(plate)
	plate_container.add_child(dirt)
	add_child(plate_container)
	dirt_layers.append(dirt)

	return plate_container

func _show_plate(index: int) -> void:
	for i in range(plates.size()):
		plates[i].visible = (i == index)
	current_plate_index = index
	_update_instruction()

func _update_instruction() -> void:
	if instruction:
		instruction.text = "Przeciągaj myszką po talerzach, aby je wyczyścić!\nTalerz %d/%d | Czas: %ds" % [current_plate_index + 1, plates_to_clean, int(time_left)]

func _on_timer_timeout():
	if not game_active:
		return
		
	time_left -= 1.0
	_update_instruction()
	
	if time_left <= 0:
		_fail_minigame("Czas minął!")

func _check_plate_clean(mouse_pos: Vector2) -> void:
	var current_plate = plates[current_plate_index]
	if current_plate.get_global_rect().has_point(mouse_pos):
		_clean_plate()

func _clean_plate() -> void:
	var current_dirt = dirt_layers[current_plate_index]
	current_dirt.modulate.a = max(current_dirt.modulate.a - 0.02, 0)

	if current_dirt.modulate.a <= 0:
		_plate_cleaned()

func _plate_cleaned() -> void:
	game_active = false
	var current_plate = plates[current_plate_index]

	# Animate plate sliding to the right
	var tween = create_tween()
	tween.tween_property(current_plate, "position:x", size.x + 80, 0.9).as_relative()
	tween.tween_callback(Callable(self, "_on_plate_animation_complete"))

func _on_plate_animation_complete() -> void:
	if current_plate_index < plates_to_clean - 1:
		current_plate_index += 1
		_show_plate(current_plate_index)
		game_active = true
	else:
		_success()

func _fail_minigame(reason: String = "") -> void:
	game_active = false
	if timer:
		timer.stop()
	
	instruction.text = "Przegrałeś! " + reason
	instruction.modulate = Color(1, 0, 0)
	
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://UI/lose_screen.tscn")

func _success() -> void:
	game_active = false
	if timer:
		timer.stop()
		
	instruction.text = "✅ Wszystkie talerze czyste!"
	instruction.modulate = Color(0, 1, 0)

	await get_tree().create_timer(1.5).timeout

	_mark_minigame_completed()  # Mark as completed

	var item = {
		"texture": minigame_item_texture,
		"value": 500,
		"name": "Clean Plate",
		"type": "kitchen"
	}
	emit_signal("minigame_finished", item)
