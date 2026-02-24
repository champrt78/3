@tool
extends Node2D
## Drop this on a platform edge to see jump reachability.

const SPEED: float = 200.0
const JUMP_VEL: float = -350.0
const GRAVITY: float = 980.0
const TILE: float = 8.0

@export var show_reach: bool = true:
	set(value):
		show_reach = value
		queue_redraw()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()

func _draw() -> void:
	if not show_reach:
		return

	var total_air_time: float = 2.0 * absf(JUMP_VEL) / GRAVITY
	var max_range: int = 22
	var max_fall: int = 15

	var dx: int = -max_range
	while dx <= max_range:
		var gap_px: float = absf(float(dx)) * TILE
		var time_to_cross: float = 0.0
		if gap_px > 0.0:
			time_to_cross = gap_px / SPEED

		var jump_h: float = 0.0
		if time_to_cross <= total_air_time:
			jump_h = -JUMP_VEL * time_to_cross - 0.5 * GRAVITY * time_to_cross * time_to_cross
		var max_up: int = int(jump_h / TILE)

		var fall_h: float = 0.5 * GRAVITY * time_to_cross * time_to_cross
		var max_down: int = int(fall_h / TILE)
		if max_down > max_fall:
			max_down = max_fall

		var dy: int = -max_down
		while dy <= max_up:
			var difficulty: float = 0.0
			var h_ratio: float = 0.0
			if total_air_time > 0.0:
				h_ratio = time_to_cross / total_air_time

			if dy >= 0:
				var v_ratio: float = 0.0
				if jump_h > 0.0:
					v_ratio = float(dy) * TILE / jump_h
				difficulty = v_ratio
				if h_ratio > difficulty:
					difficulty = h_ratio
			else:
				difficulty = h_ratio

			var color: Color
			if difficulty < 0.5:
				color = Color(0.1, 0.9, 0.1, 0.2)
			elif difficulty < 0.8:
				color = Color(0.9, 0.8, 0.1, 0.2)
			else:
				color = Color(0.9, 0.2, 0.1, 0.15)

			var rect_x: float = float(dx) * TILE
			var rect_y: float = -float(dy) * TILE - TILE
			draw_rect(Rect2(rect_x, rect_y, TILE, TILE), color)
			dy += 1
		dx += 1

	# Crosshair
	draw_line(Vector2(-6, 0), Vector2(6, 0), Color.WHITE, 1.0)
	draw_line(Vector2(0, -6), Vector2(0, 6), Color.WHITE, 1.0)
