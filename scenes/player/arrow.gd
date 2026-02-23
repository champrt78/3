extends Area2D

const SPEED := 500.0
const MAX_DISTANCE := 700.0

var direction := 1.0
var distance_traveled := 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	var move := SPEED * direction * delta
	position.x += move
	distance_traveled += abs(move)
	if distance_traveled >= MAX_DISTANCE:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		body.kill()
		queue_free()
	elif body.is_in_group("world"):
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("switches"):
		area.activate()
		queue_free()
