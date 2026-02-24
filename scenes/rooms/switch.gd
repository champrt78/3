extends Area2D

@export var target_path: NodePath
@export var move_offset := Vector2(0, -80)
@export var move_duration := 0.5

var activated := false
var flash_timer := 0.0
const FLASH_SPEED := 5.0
# Size in screen pixels: 1/4 tile wide × 1/2 tile high (tile = 24px at 3x scale)
const SWITCH_W := 6.0
const SWITCH_H := 12.0

func _ready() -> void:
	add_to_group("switches")
	# Override collision shape to match visual size
	for child in get_children():
		if child is CollisionShape2D:
			var rect := RectangleShape2D.new()
			rect.size = Vector2(SWITCH_W, SWITCH_H)
			child.shape = rect
	# Hide any child sprite — we draw ourselves
	for child in get_children():
		if child is Sprite2D:
			child.visible = false

func _process(delta: float) -> void:
	if not activated:
		flash_timer += delta
		queue_redraw()

func _draw() -> void:
	var rect := Rect2(-SWITCH_W / 2, -SWITCH_H / 2, SWITCH_W, SWITCH_H)
	if activated:
		draw_rect(rect, Color(0.2, 0.9, 0.2))
	else:
		var t := (sin(flash_timer * FLASH_SPEED) + 1.0) / 2.0
		var color := Color(0.9, 0.2, 0.1).lerp(Color(0.9, 0.8, 0.1), t)
		draw_rect(rect, color)

func activate() -> void:
	if activated:
		return
	activated = true
	AudioManager.play("switch_click")
	queue_redraw()

	if target_path:
		var target: Node = get_node(target_path)
		if target:
			if target.has_method("activate"):
				target.activate()
			else:
				var tween: Tween = create_tween()
				tween.tween_property(target, "position",
					target.position + move_offset, move_duration)
