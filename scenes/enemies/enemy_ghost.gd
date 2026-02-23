extends Area2D
## Ghost — starts dormant (floating idle). Gets alerted by missed arrows
## hitting walls, then goes aggressive with swooping attacks.

## Dormant = slow, predictable swoops. Alerted = fast, aggressive.
@export var swoop_distance := 120.0

# Dormant timing (chill, readable)
const DORMANT_INTERVAL := 4.0
const DORMANT_SPEED := 1.5
const DORMANT_TELEGRAPH := 1.0

# Alerted timing (oh no)
const ALERTED_INTERVAL := 1.8
const ALERTED_SPEED := 3.5
const ALERTED_TELEGRAPH := 0.3

var swoop_interval := DORMANT_INTERVAL
var swoop_speed := DORMANT_SPEED
var telegraph_time := DORMANT_TELEGRAPH

enum State { IDLE, TELEGRAPH, SWOOPING, RETURNING }

var state := State.IDLE
var start_pos := Vector2.ZERO
var timer := 0.0
var swoop_progress := 0.0
var idle_bob := 0.0
var alerted := false

func _ready() -> void:
	start_pos = global_position
	add_to_group("enemies")
	add_to_group("ghosts")
	body_entered.connect(_on_body_entered)
	# Dormant = dim, slow swoops
	modulate = Color(1, 1, 1, 0.5)

func alert() -> void:
	"""Called when an arrow hits a wall — go aggressive."""
	if alerted:
		return
	alerted = true
	# Switch to fast, aggressive timing
	swoop_interval = ALERTED_INTERVAL
	swoop_speed = ALERTED_SPEED
	telegraph_time = ALERTED_TELEGRAPH
	timer = 0.0
	# Glow bright — your ass is grass
	modulate = Color(1, 1, 1, 1.0)

func _physics_process(delta: float) -> void:
	match state:
		State.IDLE:
			timer += delta
			idle_bob += delta
			global_position.y = start_pos.y + sin(idle_bob * 2.0) * 4.0
			if timer >= swoop_interval:
				state = State.TELEGRAPH
				timer = 0.0

		State.TELEGRAPH:
			timer += delta
			# Flash to warn player
			modulate.a = 0.4 + 0.6 * sin(timer * 20.0)
			if timer >= telegraph_time:
				state = State.SWOOPING
				swoop_progress = 0.0
				modulate.a = 1.0

		State.SWOOPING:
			swoop_progress += delta * swoop_speed
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
