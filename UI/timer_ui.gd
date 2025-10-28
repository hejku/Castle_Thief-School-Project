extends CanvasLayer

@onready var timer_label = $MarginContainer/Label
@onready var background = $MarginContainer/ColorRect

func _ready():
	# Position at top right
	$MarginContainer.anchor_left = 1.0
	$MarginContainer.anchor_top = 0.0
	$MarginContainer.anchor_right = 1.0
	$MarginContainer.anchor_bottom = 0.0
	$MarginContainer.offset_left = -150  # Width
	$MarginContainer.offset_top = 10
	$MarginContainer.offset_right = -10
	$MarginContainer.offset_bottom = 50   # Height
	
	# Background styling
	background.color = Color(0, 0, 0, 0.7)
	background.size = Vector2(140, 40)
	
	# Label styling
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	timer_label.add_theme_font_size_override("font_size", 20)
	timer_label.add_theme_color_override("font_color", Color.WHITE)

func _process(_delta):
	if GameState.game_timer_active:
		timer_label.text = GameState.get_time_formatted()
	else:
		timer_label.text = "00:00"
