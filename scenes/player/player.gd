extends CharacterBody2D

const SPEED := 200.0
const JUMP_VELOCITY := -350.0
const COYOTE_TIME := 0.08
const AIM_POWER_MIN := 200.0
const AIM_POWER_MAX := 500.0
const AIM_CHARGE_SPEED := 400.0
const AIM_ROTATE_SPEED := 2.5

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var was_on_floor := false
var coyote_timer := 0.0
var facing_right := true
var on_vine: bool = false
var vine_ref: Node2D = null

# Aiming state
var is_aiming := false
var aim_angle := 0.0
var aim_power := AIM_POWER_MIN
var aim_arc_line: Line2D = null

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
	aim_arc_line = Line2D.new()
	aim_arc_line.width = 1.5
	aim_arc_line.default_color = Color(1, 1, 1, 0.4)
	aim_arc_line.visible = false
	add_child(aim_arc_line)

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
	if on_vine:
		_process_vine(delta)
		_update_sprite(delta)
		return

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
	if Input.is_action_just_pressed("jump") and not is_aiming:
		if is_on_floor() or coyote_timer > 0:
			velocity.y = JUMP_VELOCITY
			coyote_timer = 0.0
			AudioManager.play("jump")

	# Horizontal movement
	if not is_aiming:
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

	var moving := abs(velocity.x) > 10.0
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
		aim_angle = -0.5 if facing_right else PI + 0.5
		aim_power = AIM_POWER_MIN
		aim_arc_line.visible = true

	# While holding
	if is_aiming and Input.is_action_pressed("shoot"):
		var vert := 0.0
		if Input.is_action_pressed("jump"):
			vert = -1.0

		if facing_right:
			aim_angle -= vert * AIM_ROTATE_SPEED * delta
			aim_angle = clamp(aim_angle, -PI * 0.85, -0.1)
		else:
			aim_angle += vert * AIM_ROTATE_SPEED * delta
			aim_angle = clamp(aim_angle, PI + 0.1, PI + PI * 0.85)

		aim_power = min(aim_power + AIM_CHARGE_SPEED * delta, AIM_POWER_MAX)
		_draw_aim_arc()

	# Release to fire
	if is_aiming and Input.is_action_just_released("shoot"):
		_fire_arrow()

func _draw_aim_arc() -> void:
	aim_arc_line.clear_points()
	var launch_vel := Vector2(cos(aim_angle), sin(aim_angle)) * aim_power
	var sim_pos := Vector2.ZERO
	var sim_vel := launch_vel
	var step := 0.03
	var points := 25

	for i in points:
		aim_arc_line.add_point(sim_pos)
		sim_vel.y += gravity * step
		sim_pos += sim_vel * step

func _fire_arrow() -> void:
	GameManager.add_strike()
	AudioManager.play("arrow_fire")
	var arrow = arrow_scene.instantiate()
	arrow.global_position = global_position
	arrow.launch_velocity = Vector2(cos(aim_angle), sin(aim_angle)) * aim_power
	get_parent().add_child(arrow)
	_cancel_aim()

func _cancel_aim() -> void:
	is_aiming = false
	aim_arc_line.visible = false
	aim_arc_line.clear_points()

func _on_landed() -> void:
	# At max strikes, floor touch = death
	if GameManager.is_dead():
		AudioManager.play("death_strike")
		GameManager.die()
		return
	AudioManager.play("land")
	GameManager.add_strike()

func _process_vine(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		release_vine()

func grab_vine(vine: Node2D) -> void:
	on_vine = true
	vine_ref = vine
	velocity = Vector2.ZERO
	_cancel_aim()
	AudioManager.play("vine_grab")

func release_vine() -> void:
	if vine_ref and vine_ref.has_method("get_release_velocity"):
		velocity = vine_ref.get_release_velocity()
	on_vine = false
	vine_ref = null
	AudioManager.play("vine_drop")

func kill() -> void:
	AudioManager.play("death_strike")
	GameManager.die()

func kill_silent() -> void:
	"""Kill without playing default death sound (caller handles audio)."""
	GameManager.die()
