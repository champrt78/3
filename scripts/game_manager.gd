extends Node

## Autoload singleton — tracks the pool and current room.

signal pool_changed(new_value: int)
signal player_died
signal room_cleared

const MAX_POOL := 3

var pool: int = MAX_POOL
var current_room_path: String = ""

## List of room scene paths in order.
var rooms: Array[String] = [
	"res://scenes/rooms/room_01.tscn",
	"res://scenes/rooms/room_02.tscn",
]

func _ready() -> void:
	pool = MAX_POOL

func spend() -> bool:
	"""Spend 1 from the pool. Returns true if spent, false if pool is empty."""
	if pool <= 0:
		return false
	pool -= 1
	pool_changed.emit(pool)
	return true

func get_pool() -> int:
	return pool

func reset_pool() -> void:
	pool = MAX_POOL
	pool_changed.emit(pool)

func die() -> void:
	player_died.emit()
	reset_pool()
	# Reload current room
	get_tree().reload_current_scene()

func clear_room() -> void:
	room_cleared.emit()
	reset_pool()
	# Load next room
	var current_index := rooms.find(current_room_path)
	if current_index >= 0 and current_index < rooms.size() - 1:
		get_tree().change_scene_to_file(rooms[current_index + 1])
	else:
		# Last room — you win! For now just reload.
		print("You beat all rooms!")
		get_tree().change_scene_to_file(rooms[0])
