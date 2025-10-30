extends Node  

var last_room: String = ""
var last_door: String = ""
var last_position: Vector2 = Vector2.ZERO


var game_time_left: float = 300.0 
var game_timer_active: bool = false
var game_timer: Timer

func _ready():

	game_timer = Timer.new()
	game_timer.wait_time = 1.0
	game_timer.timeout.connect(_on_game_timer_timeout)
	add_child(game_timer)

func start_game_timer():
	game_timer_active = true
	game_timer.start()

func stop_game_timer():
	game_timer_active = false
	game_timer.stop()

func reset_game_timer():
	game_time_left = 300.0  
	game_timer_active = false

func _on_game_timer_timeout():
	if game_timer_active:
		game_time_left -= 1.0
		if game_time_left <= 0:
			game_time_left = 0
			game_timer_active = false
			_time_up()

func _time_up():
	print("TIME'S UP! Game over!")
	get_tree().change_scene_to_file("res://UI/lose_screen.tscn")

func get_time_formatted() -> String:
	var minutes = int(game_time_left) / 60
	var seconds = int(game_time_left) % 60
	return "%02d:%02d" % [minutes, seconds]
