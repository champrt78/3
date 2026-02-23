extends CharacterBody2D
## Ground jumper — sits in one spot, jumps up and down, blocks vertical space.

@export var jump_height := -300.0
@export var jump_interval := 1.5
@export var ground_wait := 0.8

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var timer := 0.0
var is_grounded := true

func _ready() -> void:
	add_to_group("enemies")

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		is_grounded = false
	else:
		velocity.x = 0
		if not is_grounded:
			# Just landed
			is_grounded = true
			timer = 0.0

		# Wait on ground, then jump
		timer += delta
		if timer >= ground_wait:
			velocity.y = jump_height
			timer = 0.0

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
