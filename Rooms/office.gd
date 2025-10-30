extends Node2D

@onready var player = $Player
@export var biurko_minigame_scene: PackedScene = preload("res://Minigames/BiurkoMinigame.tscn")

var minigame_instance: Control = null
var minigame_layer: CanvasLayer = null

func _ready() -> void:
	var timer_ui = preload("res://UI/TimerUI.tscn").instantiate()
	add_child(timer_ui)
	minigame_layer = get_node_or_null("MinigameLayer")
	if not minigame_layer:
		minigame_layer = CanvasLayer.new()
		minigame_layer.name = "MinigameLayer"
		add_child(minigame_layer)

	var biurko = get_node_or_null("Biurko")
	if biurko:
		biurko.connect("pressed", Callable(self, "_on_biurko_pressed"))
	else:
		print("⚠️ Nie znaleziono obiektu 'Biurko' w tej scenie!")

	if GameState.last_room == "Office":
		player.global_position = GameState.last_position
	else:
		var start_pos = get_node_or_null("StartPosition")
		if start_pos:
			player.global_position = start_pos.global_position
		else:
			push_error("Brakuje Position2D o nazwie StartPosition w scenie Office!")

func _on_biurko_pressed() -> void:
	_start_minigame(biurko_minigame_scene)

func _start_minigame(scene: PackedScene) -> void:
	if minigame_instance and minigame_instance.is_inside_tree():
		return

	minigame_instance = scene.instantiate()
	minigame_layer.add_child(minigame_instance)

	await get_tree().process_frame

	if minigame_instance is Control:
		minigame_instance.set_anchors_preset(Control.PRESET_FULL_RECT)
		minigame_instance.offset_left = 0
		minigame_instance.offset_top = 0
		minigame_instance.offset_right = 0
		minigame_instance.offset_bottom = 0
		minigame_instance.size = get_viewport_rect().size
		minigame_instance.position = Vector2.ZERO

	player.set_process(false)
	player.set_physics_process(false)

	if minigame_instance.has_signal("minigame_finished"):
		minigame_instance.connect("minigame_finished", Callable(self, "_on_minigame_finished"))


func _on_minigame_finished(item) -> void:
	player.set_process(true)
	player.set_physics_process(true)

	if item and GlobalInventory:
		GlobalInventory.add_item(item)
		print("Item added to global inventory from office minigame!")

	if minigame_instance:
		minigame_instance.queue_free()
		minigame_instance = null
