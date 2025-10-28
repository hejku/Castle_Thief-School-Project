extends Label

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP

func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		get_tree().change_scene_to_file("res://UI/starting_screen.tscn")
