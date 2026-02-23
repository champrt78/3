extends Area2D

@export var target_path: NodePath
@export var move_offset := Vector2(0, -80)
@export var move_duration := 0.5

var activated := false

func _ready() -> void:
	add_to_group("switches")

func activate() -> void:
	if activated:
		return
	activated = true
	AudioManager.play("switch_click")

	# Visual feedback
	modulate = Color(0.5, 1.0, 0.5)

	# Move the target platform
	if target_path:
		var target := get_node(target_path)
		if target:
			var tween := create_tween()
			tween.tween_property(target, "position",
				target.position + move_offset, move_duration)
