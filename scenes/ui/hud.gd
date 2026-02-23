extends CanvasLayer

@onready var dots: Array[Sprite2D] = []

const DOT_SIZE := 12
const DOT_SPACING := 24
const DOT_MARGIN := 20

func _ready() -> void:
	GameManager.pool_changed.connect(_on_pool_changed)
	_create_dots()

func _create_dots() -> void:
	# Clear existing
	for dot in dots:
		dot.queue_free()
	dots.clear()

	# Create 3 dots in top-left corner
	for i in GameManager.MAX_POOL:
		var dot := Sprite2D.new()
		dot.texture = _make_circle_texture()
		dot.position = Vector2(
			DOT_MARGIN + i * DOT_SPACING,
			DOT_MARGIN
		)
		add_child(dot)
		dots.append(dot)

func _make_circle_texture() -> ImageTexture:
	var img := Image.create(DOT_SIZE, DOT_SIZE, false, Image.FORMAT_RGBA8)
	var center := Vector2(DOT_SIZE / 2.0, DOT_SIZE / 2.0)
	var radius := DOT_SIZE / 2.0
	for x in DOT_SIZE:
		for y in DOT_SIZE:
			if Vector2(x, y).distance_to(center) <= radius:
				img.set_pixel(x, y, Color.WHITE)
			else:
				img.set_pixel(x, y, Color.TRANSPARENT)
	return ImageTexture.create_from_image(img)

func _on_pool_changed(new_value: int) -> void:
	for i in dots.size():
		if i < new_value:
			dots[i].modulate = Color.WHITE
		else:
			dots[i].modulate = Color(1, 1, 1, 0.15)
