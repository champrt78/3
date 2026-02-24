extends Area2D
## Instant death on contact — lava with bubbling particle effects.

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_setup_particles()

func _make_fade_ramp() -> GradientTexture1D:
	## Fades particle alpha to 0 at end of life.
	var grad := Gradient.new()
	grad.set_color(0, Color.WHITE)
	grad.add_point(0.7, Color.WHITE)
	grad.set_color(grad.get_point_count() - 1, Color(1, 1, 1, 0))
	var tex := GradientTexture1D.new()
	tex.gradient = grad
	return tex

func _make_lava_color_ramp() -> GradientTexture1D:
	## Random initial color: red, orange, yellow — each particle picks one.
	var grad := Gradient.new()
	grad.set_color(0, Color(0.9, 0.2, 0.1, 0.9))       # red
	grad.add_point(0.5, Color(1.0, 0.5, 0.1, 0.9))      # orange
	grad.set_color(grad.get_point_count() - 1, Color(1.0, 0.9, 0.3, 0.9))  # yellow
	var tex := GradientTexture1D.new()
	tex.gradient = grad
	return tex

func _setup_particles() -> void:
	var emission_width := 300.0
	var half_height := 12.0
	for child in get_children():
		if child is CollisionShape2D and child.shape is RectangleShape2D:
			emission_width = child.shape.size.x / 2.0
			half_height = child.shape.size.y / 2.0
			break

	var surface_y := -half_height
	var fade := _make_fade_ramp()
	var colors := _make_lava_color_ramp()

	# Rising blobs — shoot up and fade at peak
	var blobs := GPUParticles2D.new()
	blobs.amount = 12
	blobs.lifetime = 0.5
	blobs.local_coords = false

	var blob_mat := ParticleProcessMaterial.new()
	blob_mat.direction = Vector3(0, -1, 0)
	blob_mat.spread = 15.0
	blob_mat.initial_velocity_min = 15.0
	blob_mat.initial_velocity_max = 35.0
	blob_mat.gravity = Vector3(0, 70, 0)
	blob_mat.scale_min = 3.0
	blob_mat.scale_max = 5.0
	blob_mat.color_ramp = fade
	blob_mat.color_initial_ramp = colors
	blob_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	blob_mat.emission_box_extents = Vector3(emission_width, 0, 0)

	blobs.process_material = blob_mat
	blobs.position = Vector2(0, surface_y)
	add_child(blobs)

	# Fast sparks — quicker, smaller
	var sparks := GPUParticles2D.new()
	sparks.amount = 6
	sparks.lifetime = 0.4
	sparks.local_coords = false

	var spark_mat := ParticleProcessMaterial.new()
	spark_mat.direction = Vector3(0, -1, 0)
	spark_mat.spread = 25.0
	spark_mat.initial_velocity_min = 25.0
	spark_mat.initial_velocity_max = 45.0
	spark_mat.gravity = Vector3(0, 90, 0)
	spark_mat.scale_min = 2.0
	spark_mat.scale_max = 3.0
	spark_mat.color_ramp = fade
	spark_mat.color_initial_ramp = colors
	spark_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	spark_mat.emission_box_extents = Vector3(emission_width, 0, 0)

	sparks.process_material = spark_mat
	sparks.position = Vector2(0, surface_y)
	add_child(sparks)

	# Surface pops — tiny bursts sideways
	var pops := GPUParticles2D.new()
	pops.amount = 10
	pops.lifetime = 0.25
	pops.local_coords = false

	var pop_mat := ParticleProcessMaterial.new()
	pop_mat.direction = Vector3(0, -1, 0)
	pop_mat.spread = 80.0
	pop_mat.initial_velocity_min = 8.0
	pop_mat.initial_velocity_max = 20.0
	pop_mat.gravity = Vector3(0, 30, 0)
	pop_mat.scale_min = 1.0
	pop_mat.scale_max = 2.0
	pop_mat.color_ramp = fade
	pop_mat.color_initial_ramp = colors
	pop_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pop_mat.emission_box_extents = Vector3(emission_width, 0, 0)

	pops.process_material = pop_mat
	pops.position = Vector2(0, surface_y)
	add_child(pops)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("kill_silent"):
		AudioManager.play("death_lava")
		body.kill_silent()
	elif body.has_method("kill"):
		AudioManager.play("death_lava")
		body.kill()
