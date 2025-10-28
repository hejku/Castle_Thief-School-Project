extends Control

signal minigame_finished(item)

@export var success_zone_start := 40
@export var success_zone_end := 60
@export var speed := 150
@export var minigame_item_texture: Texture2D = preload("res://item/mis.webp")
@export var minigame_id := "teddy_bear_minigame"  # Unique ID for this minigame
@onready var instruction = $Label
@onready var background = $Background
@onready var bar = $TextureProgressBar
@onready var success_zone = $SuccessZone 
@onready var button = $Button
@onready var timer = $Timer

var direction := 1
var progress_value := 0
var game_active := true

var max_attempts := 3
var attempts_left := max_attempts

const BAR_WIDTH := 800
const BAR_HEIGHT := 40

func _ready():
	# Check if minigame was already completed
	if _is_minigame_completed():
		game_active = false
		# Hide all UI elements
		background.visible = false
		bar.visible = false
		success_zone.visible = false
		button.visible = false
		timer.stop()
		
		# Show message and close immediately
		instruction.text = "Minigra już ukończona!"
		instruction.modulate = Color(1, 0.5, 0)
		await get_tree().create_timer(1.5).timeout
		emit_signal("minigame_finished", null)
		return
	
	# Full screen
	anchor_left = 0
	anchor_top = 0
	anchor_right = 1
	anchor_bottom = 1
	size = get_viewport_rect().size
	
	background.color = Color(0, 0, 0, 0.6)
	background.anchor_left = 0
	background.anchor_top = 0
	background.anchor_right = 1
	background.anchor_bottom = 1
	background.offset_left = 0
	background.offset_top = 0
	background.offset_right = 0
	background.offset_bottom = 0

	# Bar
	bar.min_value = 0
	bar.max_value = 100
	bar.value = progress_value
	bar.anchor_left = 0.5
	bar.anchor_right = 0.5
	bar.anchor_top = 0.5
	bar.anchor_bottom = 0.5
	@warning_ignore("integer_division")
	bar.offset_left = -int(BAR_WIDTH / 2)
	@warning_ignore("integer_division")
	bar.offset_right = int(BAR_WIDTH / 2)
	@warning_ignore("integer_division")
	bar.offset_top = -int(BAR_HEIGHT / 2)
	@warning_ignore("integer_division")
	bar.offset_bottom = int(BAR_HEIGHT / 2)

	# Bar textures
	if not bar.texture_under:
		bar.texture_under = _make_colored_texture(Color(0.2, 0.2, 0.2), BAR_WIDTH, BAR_HEIGHT)
	if not bar.texture_progress:
		bar.texture_progress = _make_colored_texture(Color(0.2, 0.8, 0.2), BAR_WIDTH, BAR_HEIGHT)

	# Success Zone (sibling)
	var start_px = int(BAR_WIDTH * success_zone_start / 100.0)
	var end_px = int(BAR_WIDTH * success_zone_end / 100.0)

	success_zone.anchor_left = 0.5
	success_zone.anchor_right = 0.5
	success_zone.anchor_top = 0.5
	success_zone.anchor_bottom = 0.5
	@warning_ignore("integer_division")
	success_zone.offset_left = -int(BAR_WIDTH / 2) + start_px
	@warning_ignore("integer_division")
	success_zone.offset_right = -int(BAR_WIDTH / 2) + end_px
	@warning_ignore("integer_division")
	success_zone.offset_top = -int(BAR_HEIGHT / 2)
	@warning_ignore("integer_division")
	success_zone.offset_bottom = int(BAR_HEIGHT / 2)
	success_zone.color = Color(0, 1, 1, 0.3)

	# Button lower
	button.text = "Kliknij!"
	button.anchor_left = 0.5
	button.anchor_right = 0.5
	button.anchor_top = 0.8
	button.anchor_bottom = 0.6
	button.offset_left = -50
	button.offset_right = 50
	button.offset_top = -20
	button.offset_bottom = 20
	button.pressed.connect(_on_button_pressed)

	# Timer
	timer.wait_time = 0.02
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	
	_update_instruction_text()

func _is_minigame_completed() -> bool:
	var global_inventory = get_node_or_null("/root/GlobalInventory")
	if global_inventory and global_inventory.has_method("is_minigame_completed"):
		return global_inventory.is_minigame_completed(minigame_id)
	return false

func _mark_minigame_completed():
	var global_inventory = get_node_or_null("/root/GlobalInventory")
	if global_inventory and global_inventory.has_method("mark_minigame_completed"):
		global_inventory.mark_minigame_completed(minigame_id)

func _update_instruction_text():
	if instruction:
		instruction.text = "Kliknij przycisk, gdy pasek będzie w niebieskiej strefie!\nPozostałe próby: %d" % attempts_left

func _make_colored_texture(color: Color, width: int, height: int) -> Texture2D:
	var img = Image.create(width, height, false, Image.FORMAT_RGBA8)
	img.fill(color)
	return ImageTexture.create_from_image(img)

func _on_timer_timeout():
	if not game_active:
		return

	progress_value += direction * speed * timer.wait_time
	if progress_value >= 100:
		progress_value = 100
		direction = -1
	elif progress_value <= 0:
		progress_value = 0
		direction = 1

	bar.value = progress_value

func _on_button_pressed():
	if not game_active:
		return

	if progress_value >= success_zone_start and progress_value <= success_zone_end:
		_success()
	else:
		_attempt_failed()

func _attempt_failed():
	attempts_left -= 1
	
	if attempts_left > 0:
		game_active = false
		timer.stop()
		await _show_message("Nie udało się! Spróbuj ponownie.", Color(1, 0.5, 0))
		game_active = true
		timer.start()
		_update_instruction_text()
	else:
		_fail()

# Show success/fail messages dynamically near bottom
func _show_message(text: String, color: Color):
	var msg_label = Label.new()
	msg_label.text = text
	msg_label.modulate = color
	msg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# Anchor near bottom
	msg_label.anchor_left = 0.5
	msg_label.anchor_right = 0.5
	msg_label.anchor_top = 0.9
	msg_label.anchor_bottom = 0.9

	msg_label.offset_left = -200
	msg_label.offset_right = 200
	msg_label.offset_top = -20
	msg_label.offset_bottom = 20

	add_child(msg_label)

	await get_tree().create_timer(1.5).timeout
	msg_label.queue_free()

func _success():
	game_active = false
	timer.stop()
	await _show_message("Udało ci się ukraść misia!", Color(0, 1, 0))
	
	_mark_minigame_completed()  # Mark as completed

	var item = {
		"texture": minigame_item_texture,
		"value": 750,
		"name": "Misiek",
		"type": "toy"
	}
	emit_signal("minigame_finished", item)

func _fail():
	game_active = false
	timer.stop()
	instruction.text = "Przegrałeś!"
	instruction.modulate = Color(1, 0, 0)
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://UI/lose_screen.tscn")
