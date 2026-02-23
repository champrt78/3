extends CharacterBody2D

const SPEED := 60.0

@export var patrol_distance := 100.0

var start_x := 0.0
var direction := 1.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	start_x = global_position.x
	add_to_group("enemies")

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Patrol back and forth
	velocity.x = direction * SPEED
	if global_position.x > start_x + patrol_distance:
		direction = -1.0
	elif global_position.x < start_x - patrol_distance:
		direction = 1.0

	move_and_slide()

	# Kill player on contact
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		if collision.get_collider() is CharacterBody2D:
			var body = collision.get_collider()
			if body.has_method("kill"):
				body.kill()

func kill() -> void:
	queue_free()
