extends Area2D
## Bat — hovers in a wibbly wobbly pattern. Not perfectly predictable,
## but slow enough to time a careful jump past. Or just shoot it.

@export var hover_range := 25.0

var start_pos := Vector2.ZERO
var time := 0.0
# Random-ish offsets so each bat feels different
var freq_x := 0.0
var freq_y := 0.0
var phase_x := 0.0
var phase_y := 0.0

func _ready() -> void:
	start_pos = global_position
	add_to_group("enemies")
	body_entered.connect(_on_body_entered)
	# Each bat gets slightly different movement
	freq_x = randf_range(0.8, 1.4)
	freq_y = randf_range(1.0, 1.8)
	phase_x = randf_range(0.0, TAU)
	phase_y = randf_range(0.0, TAU)

func _physics_process(delta: float) -> void:
	time += delta
	# Layer multiple sine waves for wobbly, organic-feeling drift
	var x := sin(time * freq_x + phase_x) * hover_range
	x += sin(time * freq_x * 2.3 + 1.0) * hover_range * 0.3
	var y := cos(time * freq_y + phase_y) * hover_range * 0.7
	y += cos(time * freq_y * 1.7 + 2.0) * hover_range * 0.25
	global_position = start_pos + Vector2(x, y)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("kill"):
		body.kill()

func kill() -> void:
	AudioManager.play("death_bat")
	queue_free()
