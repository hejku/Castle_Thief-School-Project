extends Area2D

@onready var prompt_label = $RichTextLabel
var player_in_area := false

func _ready() -> void:
	prompt_label.visible = false

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		player_in_area = true
	if body.is_in_group("player"):
		player_in_area = true
		prompt_label.visible = true

func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		player_in_area = false
	if body.is_in_group("player"):
		player_in_area = false
		prompt_label.visible = false
