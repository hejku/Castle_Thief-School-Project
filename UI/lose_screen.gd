extends Control

@onready var main_menu_button = $VBoxContainer/MainMenu

func _ready():
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	
	if GameState:
		GameState.stop_game_timer()

func _on_main_menu_pressed():
	if GameState:
		GameState.stop_game_timer()
		GameState.reset_game_timer()
	
	if Engine.has_singleton("GlobalInventory"):
		var global_inv = Engine.get_singleton("GlobalInventory")
		global_inv.clear_inventory()
	elif get_node_or_null("/root/GlobalInventory"):
		get_node("/root/GlobalInventory").clear_inventory()

	get_tree().change_scene_to_file("res://UI/starting_screen.tscn")
