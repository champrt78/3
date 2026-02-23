extends Area2D
## Bat — hovers/bobs in a small area, blocking a zone.

@export var hover_range := 20.0
@export var hover_speed := 1.5

var start_pos := Vector2.ZERO
var time := 0.0

func _ready() -> void:
	start_pos = global_position
	add_to_group("enemies")
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	time += delta
	# Figure-8 ish hover pattern
	global_position = start_pos + Vector2(
		sin(time * hover_speed) * hover_range,
		cos(time * hover_speed * 1.6) * hover_range * 0.6
	)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("kill"):
		body.kill()

func kill() -> void:
	queue_free()
