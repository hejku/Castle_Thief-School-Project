extends CharacterBody2D

var is_chatting = false
var player_in_chat_zone = false
var player

@onready var prompt_label = $RichTextLabel

func _ready() -> void:
	prompt_label.visible = false

func _process(_delta):
	if Input.is_action_just_pressed("interact") and player_in_chat_zone and !is_chatting:
		print("Chatting with NPC")
		$"Dialogue - goblin".start()
		is_chatting = true
		$AnimatedSprite2D.play("idle")
		prompt_label.visible = false


func _on_chat_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and !is_chatting:
		player = body
		player_in_chat_zone = true
		prompt_label.show()

func _on_chat_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_chat_zone = false
		prompt_label.hide()

func _on_dialogue__goblin_dialogue_finished() -> void:
	is_chatting = false
	
	if player_in_chat_zone:
		prompt_label.show()
