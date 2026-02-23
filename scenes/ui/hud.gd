extends CanvasLayer

@onready var dots: Array[Sprite2D] = []

const DOT_SIZE := 12
const DOT_SPACING := 24
const DOT_MARGIN := 20

# Colors for each strike level
const COLORS := [
	Color(0.2, 0.9, 0.2),   # Strike 1 — green
	Color(0.95, 0.85, 0.1),  # Strike 2 — yellow
	Color(0.95, 0.2, 0.2),   # Strike 3 — red
]

func _ready() -> void:
	GameManager.strikes_changed.connect(_on_strikes_changed)
	_create_dots()

func _create_dots() -> void:
	for dot in dots:
		dot.queue_free()
	dots.clear()

	# Create 3 dot slots stacked vertically, bottom to top (green, yellow, red)
	for i in GameManager.MAX_STRIKES:
		var dot := Sprite2D.new()
		dot.texture = _make_circle_texture()
		dot.position = Vector2(
			DOT_MARGIN,
			DOT_MARGIN + (GameManager.MAX_STRIKES - 1 - i) * DOT_SPACING
		)
		dot.visible = false
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

func _on_strikes_changed(new_value: int) -> void:
	for i in dots.size():
		if i < new_value:
			dots[i].visible = true
			dots[i].modulate = COLORS[i]  # Each dot keeps its own color
		else:
			dots[i].visible = false
