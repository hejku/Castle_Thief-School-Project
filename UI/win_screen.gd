extends Control

@onready var label_grade: Label = $CenterContainer/VBoxContainer/Label_Grade
@onready var label_points: Label = $CenterContainer/VBoxContainer/Label_Points
@onready var main_menu_button: Button = $CenterContainer/VBoxContainer/Button

@onready var global_inventory = get_node("/root/GlobalInventory")

func _ready() -> void:
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_menu_button.pressed.connect(_on_main_menu_pressed)

	var total_points: int = calculate_total_points()
	var grade: String = determine_grade(total_points)

	label_grade.text = grade
	label_points.text = str(total_points) + " pts"

	label_grade.add_theme_font_size_override("font_size", 160)
	label_points.add_theme_font_size_override("font_size", 40)
	main_menu_button.add_theme_font_size_override("font_size", 40)

func calculate_total_points() -> int:
	var total := 0
	for item in global_inventory.get_items():
		if item.has("value"):
			total += int(item["value"])
	return total

func determine_grade(points: int) -> String:
	if points < 500:
		return "F"
	elif points < 1000:
		return "E"
	elif points < 1500:
		return "D"
	elif points < 2000:
		return "C"
	elif points < 2500:
		return "B"
	elif points < 3000:
		return "A"
	else:
		return "S"

func _on_main_menu_pressed() -> void:
	global_inventory.clear_inventory()
	GameState.last_door = ""  
	get_tree().change_scene_to_file("res://UI/starting_screen.tscn")
