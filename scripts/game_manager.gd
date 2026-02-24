extends Node

## Autoload singleton — tracks strikes and current room.

signal strikes_changed(new_value: int)
signal player_died
signal room_cleared

const MAX_STRIKES := 3

var strikes: int = 0
var current_room_path: String = ""

## List of room scene paths in order.
var rooms: Array[String] = [
	"res://scenes/rooms/room_01.tscn",
	"res://scenes/rooms/room_02.tscn",
]

func _ready() -> void:
	strikes = 0

func add_strike() -> void:
	"""Add a strike. Called on floor touch or arrow shot."""
	strikes += 1
	strikes_changed.emit(strikes)
	AudioManager.play("strike_blip")

func can_shoot() -> bool:
	"""Can only shoot if under max strikes."""
	return strikes < MAX_STRIKES

func is_dead() -> bool:
	"""At max strikes, next floor touch = death."""
	return strikes >= MAX_STRIKES

func get_strikes() -> int:
	return strikes

func reset_strikes() -> void:
	strikes = 0
	strikes_changed.emit(strikes)

func die() -> void:
	player_died.emit()
	reset_strikes()
	get_tree().reload_current_scene()

func clear_room() -> void:
	room_cleared.emit()
	reset_strikes()
	# Derive current room from scene tree — no need to manually track
	current_room_path = get_tree().current_scene.scene_file_path
	var current_index := rooms.find(current_room_path)
	if current_index >= 0 and current_index < rooms.size() - 1:
		get_tree().change_scene_to_file(rooms[current_index + 1])
	else:
		print("You beat all rooms!")
		get_tree().change_scene_to_file(rooms[0])
