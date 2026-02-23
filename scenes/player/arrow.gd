extends Area2D

const MAX_LIFETIME := 3.0

var launch_velocity := Vector2.ZERO
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var lifetime := 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	# Gravity arc
	launch_velocity.y += gravity * delta
	position += launch_velocity * delta

	# Rotate arrow to match flight direction
	rotation = launch_velocity.angle()

	# Despawn after time
	lifetime += delta
	if lifetime >= MAX_LIFETIME:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		body.kill()
		queue_free()
	elif body.is_in_group("world"):
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("switches"):
		area.activate()
		queue_free()
