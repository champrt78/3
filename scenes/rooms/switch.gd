extends Area2D

@export var target_path: NodePath
@export var move_offset := Vector2(0, -80)
@export var move_duration := 0.5

var activated := false
var flash_time := 0.0
const FLASH_SPEED := 4.0

@onready var sprite: Sprite2D = $SwitchSprite

func _ready() -> void:
	add_to_group("switches")

func _process(delta: float) -> void:
	if activated:
		return
	# Flash between yellow and red (hard toggle)
	flash_time += delta * FLASH_SPEED
	if int(flash_time) % 2 == 0:
		sprite.modulate = Color(1.0, 0.9, 0.15)
	else:
		sprite.modulate = Color(1.0, 0.2, 0.15)

func activate() -> void:
	if activated:
		return
	activated = true
	AudioManager.play("switch_click")

	# Switch to green on state
	sprite.texture = preload("res://assets/sprites/switch_on.png")
	sprite.modulate = Color.WHITE

	# Move the target platform
	if target_path:
		var target: Node = get_node(target_path)
		if target:
			if target.has_method("activate"):
				target.activate()
			else:
				var tween: Tween = create_tween()
				tween.tween_property(target, "position",
					target.position + move_offset, move_duration)
