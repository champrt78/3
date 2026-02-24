extends Node2D

## A vine wrapper that starts hidden and drops into position when activated.
## Place a Vine child inside this node. The switch calls activate() on this.

@export var drop_duration := 1.5
@export var drop_distance := 200.0

var activated := false

func _ready() -> void:
	visible = false
	# Disable vine grab area until activated
	set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	for child in get_children():
		if child.has_node("GrabArea"):
			child.get_node("GrabArea").set_deferred("monitoring", false)

func activate() -> void:
	if activated:
		return
	activated = true
	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT
	# Re-enable vine grab area
	for child in get_children():
		if child.has_node("GrabArea"):
			child.get_node("GrabArea").monitoring = true
	AudioManager.play("vine_creak")

	# Start above final position and tween down
	var final_y: float = position.y
	position.y -= drop_distance

	var tween: Tween = create_tween()
	tween.tween_property(self, "position:y", final_y, drop_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
