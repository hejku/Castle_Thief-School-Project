extends Control

func _ready():
	# Set background to black
	var background = ColorRect.new()
	background.color = Color.BLACK
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	
	# Use CenterContainer for perfect centering
	var center_container = CenterContainer.new()
	center_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center_container)
	
	# Main container inside center container
	var main_container = VBoxContainer.new()
	main_container.add_theme_constant_override("separation", 30)
	center_container.add_child(main_container)
	
	# Title
	var title = Label.new()
	title.text = "Castle Thief"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color.WHITE)

# ✅ Proper font loading for Godot 4.5
	var font = load("res://UI/PrinceValiant.ttf")
	title.add_theme_font_override("font", font)

	main_container.add_child(title)


	
	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 50)
	main_container.add_child(spacer)
	
	# Play Button
	var play_button = Button.new()
	play_button.text = "Play"
	play_button.custom_minimum_size = Vector2(200, 60)
	play_button.add_theme_font_size_override("font_size", 24)
	play_button.pressed.connect(_on_play_pressed)
	main_container.add_child(play_button)
	
	# Options Button
	var options_button = Button.new()
	options_button.text = "Options"
	options_button.custom_minimum_size = Vector2(200, 60)
	options_button.add_theme_font_size_override("font_size", 24)
	options_button.pressed.connect(_on_options_pressed)
	main_container.add_child(options_button)
	
	# Quit Button
	var quit_button = Button.new()
	quit_button.text = "Quit"
	quit_button.custom_minimum_size = Vector2(200, 60)
	quit_button.add_theme_font_size_override("font_size", 24)
	quit_button.pressed.connect(_on_quit_pressed)
	main_container.add_child(quit_button)

func _on_play_pressed():
	print("Starting game...")
	
	if GameState:
		GameState.reset_game_timer()
		GameState.start_game_timer()
	
	get_tree().change_scene_to_file("res://Rooms/Hall.tscn")

func _on_options_pressed():
	print("Options button pressed - no functionality yet")

func _on_quit_pressed():
	print("Quitting game...")
	get_tree().quit()
