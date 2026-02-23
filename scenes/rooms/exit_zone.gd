extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("exit")

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.has_method("kill"):
		GameManager.clear_room()
