extends Control

@onready var play_button = $VBoxContainer/Play
@onready var options_button = $VBoxContainer/Options
@onready var creators_button = $VBoxContainer/Creators  
@onready var quit_button = $VBoxContainer/Quit

func _ready():
	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_options_pressed)
	creators_button.pressed.connect(_on_creators_pressed)  
	quit_button.pressed.connect(_on_quit_pressed)


func _on_play_pressed():
	print("Starting game...")

	if GameState:
		GameState.reset_game_timer()
		GameState.start_game_timer()

	if Engine.has_singleton("GlobalInventory"):
		var global_inv = Engine.get_singleton("GlobalInventory")
		global_inv.clear_inventory()
	elif get_node_or_null("/root/GlobalInventory"):
		get_node("/root/GlobalInventory").clear_inventory()

	get_tree().change_scene_to_file("res://Rooms/Hall.tscn")


func _on_options_pressed():
	print("Options button pressed - not implemented yet")


func _on_creators_pressed():
	print("Opening creators screen...")


func _on_quit_pressed():
	print("Quitting game...")

	if GameState:
		GameState.stop_game_timer()
		GameState.reset_game_timer()

	if Engine.has_singleton("GlobalInventory"):
		var global_inv = Engine.get_singleton("GlobalInventory")
		global_inv.clear_inventory()
	elif get_node_or_null("/root/GlobalInventory"):
		get_node("/root/GlobalInventory").clear_inventory()

	get_tree().quit()
