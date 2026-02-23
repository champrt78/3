extends Area2D
## Instant death on contact — lava, bottomless pit, etc.

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("kill"):
		AudioManager.play("death_lava")
		body.kill_silent()
