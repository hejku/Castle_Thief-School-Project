extends Area2D

signal pressed

@onready var prompt_label = $RichTextLabel
var player_in_range := false

func _ready() -> void:
	prompt_label.visible = false
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))


func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		print()
		emit_signal("pressed")

func _on_body_entered(body: Node) -> void:
	print()
	if body.is_in_group("player"):
		player_in_range = true
		prompt_label.visible = true

func _on_body_exited(body: Node) -> void:
	print()
	if body.is_in_group("player"):
		player_in_range = false
		prompt_label.visible = false
