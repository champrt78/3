extends Node2D

const SWING_SPEED := 2.5
const SWING_AMPLITUDE := 1.2
const SNAP_TIME := 2.5
const SNAP_WARNING := 0.8  # seconds before snap to start warning

@export var rope_length := 80.0

var snap_timer := 0.0
var is_occupied := false
var swing_angle := 0.0
var swing_velocity := 0.0
var player_ref: CharacterBody2D = null
var snapped := false

@onready var grab_area: Area2D = $GrabArea
@onready var rope_line: Line2D = $RopeLine
@onready var end_marker: Sprite2D = $EndMarker

func _ready() -> void:
	grab_area.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if snapped:
		return

	if is_occupied and player_ref:
		# Pendulum swing
		var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
		swing_velocity += (-gravity / rope_length) * sin(swing_angle) * delta
		swing_velocity += Input.get_axis("move_left", "move_right") * SWING_SPEED * delta
		swing_angle += swing_velocity * delta
		swing_angle = clamp(swing_angle, -SWING_AMPLITUDE, SWING_AMPLITUDE)

		# Position player at end of rope
		var offset := Vector2(sin(swing_angle), cos(swing_angle)) * rope_length
		player_ref.global_position = global_position + offset

		# Update visuals
		_update_rope(offset)

		# Snap timer
		snap_timer += delta
		if snap_timer >= SNAP_TIME:
			_snap()
		elif snap_timer >= SNAP_TIME - SNAP_WARNING:
			# Warning flash
			modulate.a = 0.5 + 0.5 * sin(snap_timer * 20.0)
	else:
		# Idle sway
		var offset := Vector2(0, rope_length)
		_update_rope(offset)

func _update_rope(end_offset: Vector2) -> void:
	if rope_line:
		rope_line.clear_points()
		rope_line.add_point(Vector2.ZERO)
		rope_line.add_point(end_offset)
	if end_marker:
		end_marker.position = end_offset

func get_release_velocity() -> Vector2:
	var tangent := Vector2(cos(swing_angle), -sin(swing_angle))
	return tangent * swing_velocity * rope_length * 1.5

func _on_body_entered(body: Node2D) -> void:
	if snapped or is_occupied:
		return
	if body is CharacterBody2D and body.has_method("grab_vine"):
		player_ref = body
		is_occupied = true
		snap_timer = 0.0
		body.grab_vine(self)

func _snap() -> void:
	snapped = true
	is_occupied = false
	if player_ref and player_ref.has_method("release_vine"):
		player_ref.release_vine()
	player_ref = null
	# Visual: hide the rope
	if rope_line:
		rope_line.visible = false
	if end_marker:
		end_marker.visible = false
	if grab_area:
		grab_area.set_deferred("monitoring", false)
