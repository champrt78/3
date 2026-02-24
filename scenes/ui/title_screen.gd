extends CanvasLayer

## Title overlay — sits on top of room_01. Big "3" built from platform tiles.
## Hides when player presses S, unfreezes gameplay.

signal start_pressed

var blink_timer := 0.0
var active := true
var tile_nodes: Array[Sprite2D] = []

# The "3" shape as a grid — each X is a platform tile
const THREE_SHAPE: Array[String] = [
	"XXXXX",
	"XXXXX",
	"....X",
	"....X",
	"..XXX",
	"..XXX",
	"....X",
	"....X",
	"XXXXX",
	"XXXXX",
]

const TILE_SIZE := 8
const TILE_SCALE := 1.5

func _ready() -> void:
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_three()

func _build_three() -> void:
	var tile_tex: Texture2D = preload("res://assets/sprites/platform_tile.png")
	var grid_w: int = THREE_SHAPE[0].length()
	var grid_h: int = THREE_SHAPE.size()
	var scaled_tile: float = TILE_SIZE * TILE_SCALE
	var total_w: float = grid_w * scaled_tile
	var total_h: float = grid_h * scaled_tile
	var start_x: float = (640.0 - total_w) / 2.0
	var start_y: float = 50.0

	for y in grid_h:
		for x in grid_w:
			if THREE_SHAPE[y][x] == "X":
				var sprite := Sprite2D.new()
				sprite.texture = tile_tex
				sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				sprite.scale = Vector2(TILE_SCALE, TILE_SCALE)
				sprite.position = Vector2(
					start_x + x * scaled_tile + scaled_tile / 2.0,
					start_y + y * scaled_tile + scaled_tile / 2.0
				)
				add_child(sprite)
				tile_nodes.append(sprite)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

	if not active:
		return

	blink_timer += delta
	$PressStart.visible = fmod(blink_timer, 1.0) < 0.65

	if Input.is_action_just_pressed("start"):
		_dismiss()

func _dismiss() -> void:
	active = false
	get_tree().paused = false
	# Hide all title elements
	for tile in tile_nodes:
		tile.visible = false
	$Controls.visible = false
	$PressStart.visible = false
	start_pressed.emit()
