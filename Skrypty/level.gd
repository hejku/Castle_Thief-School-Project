extends Node2D

@export var berlo_minigame_scene: PackedScene = preload("res://Minigames/BerloMinigame.tscn")
@export var miskrola_minigame_scene: PackedScene = preload("res://Minigames/mis_minigame.tscn")

var minigame_instance: Control = null
var minigame_layer: CanvasLayer = null

func _ready() -> void:
	if not has_node("MinigameLayer"):
		minigame_layer = CanvasLayer.new()
		minigame_layer.name = "MinigameLayer"
		add_child(minigame_layer)
	else:
		minigame_layer = $MinigameLayer

	var berlo = find_child("Berlo", true, false)
	if berlo:
		berlo.connect("pressed", Callable(self, "_on_berlo_pressed"))
	else:
		print("⚠️ Nie znaleziono obiektu 'Berlo' w tej scenie!")

	var miskrola = find_child("Mis", true, false)
	if miskrola:
		miskrola.connect("pressed", Callable(self, "_on_mis_pressed"))
	else:
		print("⚠️ Nie znaleziono obiektu 'MisKrola' w tej scenie!")

func _on_berlo_pressed() -> void:
	_start_minigame(berlo_minigame_scene)

func _on_mis_pressed() -> void:
	_start_minigame(miskrola_minigame_scene)


func _start_minigame(scene: PackedScene) -> void:
	if minigame_instance and minigame_instance.is_inside_tree():
		return

	minigame_instance = scene.instantiate()
	minigame_layer.add_child(minigame_instance)

	if minigame_instance is Control:
		minigame_instance.anchor_left = 0.5
		minigame_instance.anchor_top = 0.5
		minigame_instance.anchor_right = 0.5
		minigame_instance.anchor_bottom = 0.5
		minigame_instance.position = Vector2.ZERO

	var player = find_child("Player", true, false)
	if player:
		player.set_process(false)
		player.set_physics_process(false)

	if minigame_instance.has_signal("minigame_finished"):
		minigame_instance.connect("minigame_finished", Callable(self, "_on_minigame_finished"))


func _on_minigame_finished() -> void:
	var player = find_child("Player", true, false)
	if player:
		player.set_process(true)
		player.set_physics_process(true)

	if minigame_instance:
		minigame_instance.queue_free()
		minigame_instance = null
