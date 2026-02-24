extends Node2D

const SWING_AMPLITUDE := 0.7
const SNAP_TIME := 2.5
const COLOR_GREEN := Color(0.2, 0.8, 0.2)
const COLOR_YELLOW := Color(0.9, 0.8, 0.1)
const COLOR_RED := Color(0.9, 0.2, 0.2)
const CLIMB_SPEED := 60.0
const MIN_ROPE_POS := 20.0  # can't climb above this

@export var rope_length := 80.0

var snap_timer := 0.0
var is_occupied := false
var swing_angle := 0.0
var swing_velocity := 0.0
var player_ref: CharacterBody2D = null
var snapped := false
var creak_timer := 0.0
var player_rope_pos := 0.0  # how far down the rope the player is
var grab_cooldown := 0.0  # prevents immediate re-grab after release
const CREAK_INTERVAL := 0.6

@onready var grab_area: Area2D = $GrabArea
@onready var rope_line: Line2D = $RopeLine
@onready var end_marker: Sprite2D = $EndMarker

func _ready() -> void:
	grab_area.body_entered.connect(_on_body_entered)
	# Make grab area cover the full rope length so player can grab anywhere
	var grab_shape := RectangleShape2D.new()
	grab_shape.size = Vector2(30, rope_length)
	$GrabArea/CollisionShape2D.shape = grab_shape
	$GrabArea/CollisionShape2D.position = Vector2(0, rope_length / 2.0)
	# Start green
	if rope_line:
		rope_line.default_color = COLOR_GREEN

func _physics_process(delta: float) -> void:
	if snapped:
		return

	if grab_cooldown > 0.0:
		grab_cooldown -= delta

	if is_occupied and player_ref:
		# Climb up/down
		var climb_input: float = Input.get_axis("move_up", "move_down")
		player_rope_pos += climb_input * CLIMB_SPEED * delta
		player_rope_pos = clamp(player_rope_pos, MIN_ROPE_POS, rope_length)

		# Pendulum swing
		var grav: float = ProjectSettings.get_setting("physics/2d/default_gravity")
		swing_velocity += (-grav / player_rope_pos) * sin(swing_angle) * delta
		swing_velocity *= (1.0 - 1.5 * delta)  # damping prevents runaway velocity
		swing_angle += swing_velocity * delta
		# Bounce off max angle like hitting a wall (prevents vibration)
		if swing_angle > SWING_AMPLITUDE:
			swing_angle = SWING_AMPLITUDE
			if swing_velocity > 0.0:
				swing_velocity *= -0.3
		elif swing_angle < -SWING_AMPLITUDE:
			swing_angle = -SWING_AMPLITUDE
			if swing_velocity < 0.0:
				swing_velocity *= -0.3

		# Update visuals — rope draws to player's actual position
		var rope_end: Vector2 = player_ref.global_position - global_position
		_update_rope(rope_end)

		# Creak sound while swinging
		creak_timer += delta
		if creak_timer >= CREAK_INTERVAL:
			creak_timer -= CREAK_INTERVAL
			AudioManager.play("vine_creak", -6.0)

		# Snap timer — vine changes color: green → yellow → red → break
		snap_timer += delta
		if snap_timer >= SNAP_TIME:
			_snap()
		else:
			var t: float = snap_timer / SNAP_TIME  # 0.0 to 1.0
			if t < 0.5:
				# Green phase (first half)
				_set_vine_color(COLOR_GREEN)
			elif t < 0.8:
				# Yellow phase (middle)
				_set_vine_color(COLOR_YELLOW)
			else:
				# Red phase (final stretch) — flash to warn
				var flash: float = 0.5 + 0.5 * sin(snap_timer * 20.0)
				_set_vine_color(COLOR_RED * flash + Color.WHITE * (1.0 - flash))
	else:
		# Idle sway
		var offset := Vector2(0, rope_length)
		_update_rope(offset)

func _set_vine_color(color: Color) -> void:
	if rope_line:
		rope_line.default_color = color
	modulate = Color.WHITE  # reset modulate, color is on the line itself

func _update_rope(end_offset: Vector2) -> void:
	if rope_line:
		rope_line.clear_points()
		var mid := end_offset * 0.5
		# Rope bows opposite to swing direction + slight gravity droop
		var bend_x := -swing_velocity * 12.0 if is_occupied else 0.0
		var bend_y := 3.0
		var control := mid + Vector2(bend_x, bend_y)
		var segments := 8
		for i in range(segments + 1):
			var t := float(i) / float(segments)
			# Quadratic bezier: (1-t)^2*P0 + 2*(1-t)*t*P1 + t^2*P2
			var p := (1.0 - t) * (1.0 - t) * Vector2.ZERO + 2.0 * (1.0 - t) * t * control + t * t * end_offset
			rope_line.add_point(p)
	if end_marker:
		end_marker.position = end_offset

func get_player_target() -> Vector2:
	"""Returns world position where the player should be this frame."""
	var offset := Vector2(sin(swing_angle), cos(swing_angle)) * player_rope_pos
	return global_position + offset

func get_release_velocity() -> Vector2:
	# Horizontal: carry swing momentum (clamped to sane range)
	var h_speed: float = clampf(swing_velocity * player_rope_pos, -200.0, 200.0)
	# Vertical: normal jump strength — gravity takes over immediately
	return Vector2(h_speed, -350.0)

func get_drop_velocity() -> Vector2:
	"""Drop straight down — no swing launch."""
	return Vector2.ZERO

func _on_body_entered(body: Node2D) -> void:
	if snapped or is_occupied or grab_cooldown > 0.0:
		return
	if body is CharacterBody2D and body.has_method("grab_vine"):
		# Capture velocity before grab (grab zeroes it)
		var incoming_vel_x: float = body.velocity.x
		var local_y: float = body.global_position.y - global_position.y
		player_rope_pos = clampf(local_y, MIN_ROPE_POS, rope_length)
		# Ask player to grab — may refuse if on another vine or immune
		if not body.grab_vine(self):
			return
		player_ref = body
		is_occupied = true
		snap_timer = 0.0
		creak_timer = 0.0
		if rope_line:
			rope_line.default_color = COLOR_GREEN
		# Convert horizontal velocity to initial swing momentum
		swing_angle = 0.0
		swing_velocity = clampf(incoming_vel_x * 0.005, -1.5, 1.5)

func player_released() -> void:
	is_occupied = false
	player_ref = null
	grab_cooldown = 0.5

func _snap() -> void:
	AudioManager.play("vine_break")
	snapped = true
	is_occupied = false
	if player_ref and player_ref.has_method("snap_off_vine"):
		player_ref.snap_off_vine()
	player_ref = null
	# Visual: hide the rope
	if rope_line:
		rope_line.visible = false
	if end_marker:
		end_marker.visible = false
	if grab_area:
		grab_area.set_deferred("monitoring", false)
