extends Area2D
## Bat — erratic fluttery movement with quick direction changes.

@export var hover_range := 25.0

var start_pos := Vector2.ZERO
var time := 0.0
var freq_x := 0.0
var freq_y := 0.0
var phase_x := 0.0
var phase_y := 0.0
var flutter_timer := 0.0
var flutter_offset := Vector2.ZERO

func _ready() -> void:
	start_pos = global_position
	add_to_group("enemies")
	body_entered.connect(_on_body_entered)
	freq_x = randf_range(1.5, 2.5)
	freq_y = randf_range(2.0, 3.5)
	phase_x = randf_range(0.0, TAU)
	phase_y = randf_range(0.0, TAU)

func _physics_process(delta: float) -> void:
	time += delta

	# Smooth oval patrol path
	var x := sin(time * freq_x + phase_x) * hover_range
	var y := cos(time * freq_y + phase_y) * hover_range * 0.5

	# Flutter jitter — small random shake layered on top
	flutter_timer += delta
	if flutter_timer >= 0.12:
		flutter_timer -= 0.12
		flutter_offset = Vector2(randf_range(-2.0, 2.0), randf_range(-2.0, 1.5))

	global_position = start_pos + Vector2(x, y) + flutter_offset

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("kill"):
		body.kill()

func kill() -> void:
	AudioManager.play("death_bat")
	_spawn_death_burst()
	queue_free()

func _spawn_death_burst() -> void:
	var particles := GPUParticles2D.new()
	particles.global_position = global_position
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 10
	particles.lifetime = 0.3
	particles.local_coords = false

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 0, 0)
	mat.spread = 180.0
	mat.initial_velocity_min = 40.0
	mat.initial_velocity_max = 90.0
	mat.gravity = Vector3(0, 20, 0)
	mat.scale_min = 2.0
	mat.scale_max = 4.0
	mat.color = Color(1.0, 1.0, 1.0, 1.0)

	var grad := Gradient.new()
	grad.set_color(0, Color.WHITE)
	grad.add_point(0.6, Color.WHITE)
	grad.set_color(grad.get_point_count() - 1, Color(1, 1, 1, 0))
	var fade := GradientTexture1D.new()
	fade.gradient = grad
	mat.color_ramp = fade

	particles.process_material = mat
	get_parent().add_child(particles)
	get_tree().create_timer(0.5).timeout.connect(particles.queue_free)
