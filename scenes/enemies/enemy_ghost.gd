extends Area2D
## Ghost — floats in place, periodically swoops downward in an arc.
## Telegraphed so the player can time around it.

@export var swoop_interval := 3.0
@export var swoop_distance := 120.0
@export var swoop_speed := 2.5
@export var telegraph_time := 0.6

enum State { IDLE, TELEGRAPH, SWOOPING, RETURNING }

var state := State.IDLE
var start_pos := Vector2.ZERO
var timer := 0.0
var swoop_progress := 0.0
var idle_bob := 0.0

func _ready() -> void:
	start_pos = global_position
	add_to_group("enemies")
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	match state:
		State.IDLE:
			timer += delta
			idle_bob += delta
			# Gentle bob
			global_position.y = start_pos.y + sin(idle_bob * 2.0) * 4.0
			if timer >= swoop_interval:
				state = State.TELEGRAPH
				timer = 0.0

		State.TELEGRAPH:
			timer += delta
			# Flash/shake to warn the player
			modulate.a = 0.4 + 0.6 * sin(timer * 20.0)
			if timer >= telegraph_time:
				state = State.SWOOPING
				swoop_progress = 0.0
				modulate.a = 1.0

		State.SWOOPING:
			swoop_progress += delta * swoop_speed
			# Downward arc
			var t := clamp(swoop_progress, 0.0, 1.0)
			global_position = start_pos + Vector2(
				0,
				sin(t * PI) * swoop_distance
			)
			if swoop_progress >= 1.0:
				state = State.RETURNING
				swoop_progress = 0.0

		State.RETURNING:
			swoop_progress += delta * swoop_speed * 0.6
			var t := clamp(swoop_progress, 0.0, 1.0)
			global_position = global_position.lerp(start_pos, t)
			if swoop_progress >= 1.0:
				global_position = start_pos
				state = State.IDLE
				timer = 0.0

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("kill"):
		body.kill()

func kill() -> void:
	queue_free()
