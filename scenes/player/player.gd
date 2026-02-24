extends CharacterBody2D

const SPEED := 200.0
const JUMP_VELOCITY := -350.0
const COYOTE_TIME := 0.08
const AIM_POWER_MIN := 300.0
const AIM_POWER_MAX := 700.0
const AIM_CHARGE_SPEED := 300.0
const AIM_ROTATE_SPEED := 2.5

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var was_on_floor := false
var coyote_timer := 0.0
var facing_right := true
var on_vine: bool = false
var vine_ref: Node2D = null
var spawn_grace := true
var vine_release_frames := 0  # skip stale physics checks after vine release
var vine_grab_immunity := 0.0  # brief cooldown after release to prevent physics re-grab

# Aiming state
var is_aiming := false
var aim_angle := 0.0
var aim_power := AIM_POWER_MIN
var aim_draw_points: PackedVector2Array = PackedVector2Array()

# Sprite textures
var tex_idle: Texture2D
var tex_run: Array[Texture2D] = []
var tex_jump: Texture2D
var tex_land: Texture2D
var tex_swing: Texture2D
var run_frame := 0
var run_timer := 0.0
const RUN_ANIM_SPEED := 0.12

@onready var sprite: Sprite2D = $Sprite2D
@onready var arrow_scene: PackedScene = preload("res://scenes/player/arrow.tscn")

func _ready() -> void:
	# Load sprite textures
	tex_idle = preload("res://assets/sprites/player_idle.png")
	tex_run.append(preload("res://assets/sprites/player_run1.png"))
	tex_run.append(preload("res://assets/sprites/player_run2.png"))
	tex_run.append(preload("res://assets/sprites/player_run3.png"))
	tex_jump = preload("res://assets/sprites/player_jump.png")
	tex_land = preload("res://assets/sprites/player_land.png")
	tex_swing = preload("res://assets/sprites/player_swing.png")

	sprite.texture = tex_idle

func _physics_process(delta: float) -> void:
	if vine_grab_immunity > 0.0:
		vine_grab_immunity -= delta

	if on_vine:
		_process_vine(delta)
		_update_sprite(delta)
		return

	# After vine release, is_on_floor() is stale for 1-2 frames — force airborne
	if vine_release_frames > 0:
		vine_release_frames -= 1
		velocity.y += gravity * delta
	else:
		# Gravity
		if not is_on_floor():
			velocity.y += gravity * delta

		# Coyote time
		if was_on_floor and not is_on_floor():
			coyote_timer = COYOTE_TIME
		if coyote_timer > 0:
			coyote_timer -= delta

		# Landing — adds a strike. If already at max, die.
		if is_on_floor() and not was_on_floor:
			_on_landed()

		# Jump (only while on floor or coyote time, not while aiming)
		var wants_jump: bool = Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("move_up")
		if wants_jump and not is_aiming:
			if is_on_floor() or coyote_timer > 0:
				velocity.y = JUMP_VELOCITY
				coyote_timer = 0.0
				AudioManager.play("jump")

	# Horizontal movement (skip during vine release to preserve launch momentum)
	if not is_aiming and vine_release_frames <= 0:
		var direction := Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x = direction * SPEED
			facing_right = direction > 0
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * 0.8)

	# Flip sprite
	if sprite:
		sprite.flip_h = not facing_right

	# Aim and shoot
	_process_aiming(delta)

	was_on_floor = is_on_floor()
	move_and_slide()
	_update_sprite(delta)

func _update_sprite(delta: float) -> void:
	if not sprite:
		return

	if on_vine:
		sprite.texture = tex_swing
		return

	if not is_on_floor():
		sprite.texture = tex_jump
		run_timer = 0.0
		return

	var moving: bool = abs(velocity.x) > 10.0
	if moving:
		run_timer += delta
		if run_timer >= RUN_ANIM_SPEED:
			run_timer -= RUN_ANIM_SPEED
			run_frame = (run_frame + 1) % tex_run.size()
		sprite.texture = tex_run[run_frame]
	else:
		sprite.texture = tex_idle
		run_frame = 0
		run_timer = 0.0

func _process_aiming(delta: float) -> void:
	# Can't shoot if already at max strikes
	if not GameManager.can_shoot():
		if is_aiming:
			_cancel_aim()
		return

	# Start aiming
	if Input.is_action_just_pressed("shoot"):
		is_aiming = true
		aim_angle = -1.0 if facing_right else PI + 1.0
		aim_power = AIM_POWER_MIN

	# While holding — L/R adjusts angle
	if is_aiming and Input.is_action_pressed("shoot"):
		var dir := Input.get_axis("move_left", "move_right")
		aim_angle += dir * AIM_ROTATE_SPEED * delta
		if facing_right:
			aim_angle = clamp(aim_angle, -PI * 0.85, -0.1)
		else:
			aim_angle = clamp(aim_angle, PI + 0.1, PI + PI * 0.85)

		aim_power = min(aim_power + AIM_CHARGE_SPEED * delta, AIM_POWER_MAX)
		_draw_aim_arc()

	# Release to fire
	if is_aiming and Input.is_action_just_released("shoot"):
		_fire_arrow()

func _draw_aim_arc() -> void:
	aim_draw_points.clear()
	var launch_vel := Vector2(cos(aim_angle), sin(aim_angle)) * aim_power
	var sim_pos := Vector2.ZERO
	var sim_vel := launch_vel
	var step := 0.025
	var num_steps := 60

	for i in num_steps:
		aim_draw_points.append(sim_pos)
		sim_vel.y += gravity * 0.8 * step
		sim_pos += sim_vel * step
	queue_redraw()

func _draw() -> void:
	if not is_aiming or aim_draw_points.size() < 2:
		return
	var i := 0
	while i + 1 < aim_draw_points.size():
		draw_line(aim_draw_points[i], aim_draw_points[i + 1], Color(1, 1, 1, 0.4), 1.5)
		i += 3

func _fire_arrow() -> void:
	GameManager.add_strike()
	AudioManager.play("arrow_fire")
	var arrow: Node = arrow_scene.instantiate()
	arrow.global_position = global_position
	arrow.launch_velocity = Vector2(cos(aim_angle), sin(aim_angle)) * aim_power
	get_parent().add_child(arrow)
	_cancel_aim()

func _cancel_aim() -> void:
	is_aiming = false
	aim_draw_points.clear()
	queue_redraw()

func _on_landed() -> void:
	# First landing after spawn is free
	if spawn_grace:
		spawn_grace = false
		AudioManager.play("land")
		return
	# At max strikes, floor touch = death
	if GameManager.is_dead():
		AudioManager.play("death_strike")
		GameManager.die()
		return
	AudioManager.play("land")
	GameManager.add_strike()

func _process_vine(delta: float) -> void:
	var wants_release: bool = Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("move_up")
	if wants_release:
		if Input.is_action_pressed("move_down"):
			# Down + Jump = drop off (no launch velocity)
			drop_vine()
		else:
			# Jump = launch off with swing velocity
			release_vine()
		return

	# Move toward vine's target position using velocity + move_and_slide.
	# This keeps CharacterBody2D physics state (is_on_floor etc.) correct,
	# unlike setting global_position directly which causes floating on release.
	if vine_ref:
		var target: Vector2 = vine_ref.get_player_target()
		velocity = (target - global_position) / delta
		move_and_slide()

func grab_vine(vine: Node2D) -> bool:
	if on_vine or vine_grab_immunity > 0.0:
		return false
	on_vine = true
	vine_ref = vine
	velocity = Vector2.ZERO
	_cancel_aim()
	AudioManager.play("vine_grab")
	return true

func release_vine() -> void:
	"""Jump off vine — get swing momentum + jump boost."""
	if vine_ref:
		if vine_ref.has_method("get_release_velocity"):
			velocity = vine_ref.get_release_velocity()
		if vine_ref.has_method("player_released"):
			vine_ref.player_released()
	on_vine = false
	vine_ref = null
	was_on_floor = false
	vine_release_frames = 3
	vine_grab_immunity = 0.15
	AudioManager.play("vine_drop")

func snap_off_vine() -> void:
	"""Vine broke — just fall with current momentum, no jump boost."""
	if vine_ref:
		# Only carry horizontal swing momentum, no upward boost
		var h_speed := 0.0
		if vine_ref.has_method("get_release_velocity"):
			h_speed = vine_ref.get_release_velocity().x
		velocity = Vector2(h_speed, 0.0)
		if vine_ref.has_method("player_released"):
			vine_ref.player_released()
	on_vine = false
	vine_ref = null
	was_on_floor = false
	vine_release_frames = 3
	vine_grab_immunity = 0.15
	AudioManager.play("vine_drop")

func drop_vine() -> void:
	"""Drop off vine with no launch velocity — just fall."""
	if vine_ref and vine_ref.has_method("player_released"):
		vine_ref.player_released()
	on_vine = false
	vine_ref = null
	velocity = Vector2.ZERO
	was_on_floor = false
	vine_release_frames = 3
	vine_grab_immunity = 0.15
	AudioManager.play("vine_drop")

func kill() -> void:
	AudioManager.play("death_strike")
	GameManager.die()

func kill_silent() -> void:
	"""Kill without playing default death sound (caller handles audio)."""
	GameManager.die()
