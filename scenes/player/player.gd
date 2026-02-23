extends CharacterBody2D

const SPEED := 200.0
const JUMP_VELOCITY := -350.0
const COYOTE_TIME := 0.08

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var was_on_floor := false
var coyote_timer := 0.0
var facing_right := true
var on_vine: bool = false
var vine_ref: Node2D = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var arrow_scene: PackedScene = preload("res://scenes/player/arrow.tscn")

func _physics_process(delta: float) -> void:
	if on_vine:
		_process_vine(delta)
		return

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Coyote time
	if was_on_floor and not is_on_floor():
		coyote_timer = COYOTE_TIME
	if coyote_timer > 0:
		coyote_timer -= delta

	# Landing — costs 1 from pool
	if is_on_floor() and not was_on_floor:
		_on_landed()

	# Jump (only while on floor or coyote time)
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or coyote_timer > 0:
			velocity.y = JUMP_VELOCITY
			coyote_timer = 0.0

	# Horizontal movement
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		facing_right = direction > 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 0.8)

	# Flip sprite
	if sprite:
		sprite.flip_h = not facing_right

	# Shoot arrow
	if Input.is_action_just_pressed("shoot"):
		_shoot_arrow()

	was_on_floor = is_on_floor()
	move_and_slide()

func _on_landed() -> void:
	# Spend from pool. If pool was already 0, die.
	if GameManager.get_pool() <= 0:
		GameManager.die()
		return
	GameManager.spend()

func _shoot_arrow() -> void:
	if GameManager.get_pool() <= 0:
		return
	GameManager.spend()
	var arrow = arrow_scene.instantiate()
	arrow.global_position = global_position
	arrow.direction = 1.0 if facing_right else -1.0
	get_parent().add_child(arrow)

func _process_vine(delta: float) -> void:
	# While on vine, movement is handled by the vine script
	if Input.is_action_just_pressed("jump"):
		release_vine()

func grab_vine(vine: Node2D) -> void:
	on_vine = true
	vine_ref = vine
	velocity = Vector2.ZERO

func release_vine() -> void:
	if vine_ref and vine_ref.has_method("get_release_velocity"):
		velocity = vine_ref.get_release_velocity()
	on_vine = false
	vine_ref = null

func kill() -> void:
	GameManager.die()
