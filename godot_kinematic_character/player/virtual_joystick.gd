extends Control
## Virtual joystick for mobile touch controls
## Provides directional input similar to an analog stick

signal direction_changed(direction: Vector2)

@export var max_distance := 60.0
@export var deadzone := 0.1
@export var base_color := Color(1, 1, 1, 0.3)
@export var stick_color := Color(1, 1, 1, 0.8)
@export var active_color := Color(0.3, 0.8, 1.0, 0.9)

var touch_index := -1
var center_pos := Vector2.ZERO
var current_pos := Vector2.ZERO
var is_active := false

func _ready() -> void:
	# Set initial center position
	center_pos = size / 2

	# Make this control ignore mouse events when not needed
	mouse_filter = Control.MOUSE_FILTER_PASS

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and touch_index == -1:
			# Start tracking this touch
			touch_index = event.index
			current_pos = event.position
			is_active = true
			queue_redraw()
		elif not event.pressed and touch_index == event.index:
			# Release touch
			touch_index = -1
			current_pos = center_pos
			is_active = false
			direction_changed.emit(Vector2.ZERO)
			queue_redraw()

	elif event is InputEventScreenDrag:
		if event.index == touch_index:
			# Update stick position
			current_pos = event.position
			_update_direction()
			queue_redraw()

	# Also support mouse for testing on desktop
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and touch_index == -1:
				touch_index = 0
				current_pos = event.position
				is_active = true
				queue_redraw()
			elif not event.pressed and touch_index == 0:
				touch_index = -1
				current_pos = center_pos
				is_active = false
				direction_changed.emit(Vector2.ZERO)
				queue_redraw()

	elif event is InputEventMouseMotion:
		if touch_index == 0 and event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			current_pos = event.position
			_update_direction()
			queue_redraw()

func _update_direction() -> void:
	var direction := current_pos - center_pos

	# Limit to max distance
	if direction.length() > max_distance:
		direction = direction.normalized() * max_distance
		current_pos = center_pos + direction

	# Normalize and apply deadzone
	var normalized_direction := direction / max_distance

	if normalized_direction.length() < deadzone:
		normalized_direction = Vector2.ZERO

	direction_changed.emit(normalized_direction)

func _draw() -> void:
	# Draw joystick base (outer circle)
	var base_draw_color := base_color if not is_active else active_color.darkened(0.5)
	draw_circle(center_pos, max_distance, base_draw_color)
	draw_arc(center_pos, max_distance, 0, TAU, 32, Color(1, 1, 1, 0.5), 2.0)

	# Draw center dot
	draw_circle(center_pos, 4.0, Color(1, 1, 1, 0.6))

	# Draw joystick stick (inner circle)
	var stick_pos := center_pos
	if is_active:
		var direction := current_pos - center_pos
		if direction.length() > max_distance:
			direction = direction.normalized() * max_distance
		stick_pos = center_pos + direction

	var stick_draw_color := stick_color if not is_active else active_color
	draw_circle(stick_pos, 25.0, stick_draw_color)
	draw_arc(stick_pos, 25.0, 0, TAU, 24, Color(1, 1, 1, 0.9), 2.0)

	# Draw directional indicator lines when active
	if is_active:
		var direction := current_pos - center_pos
		if direction.length() > deadzone * max_distance:
			var angle := direction.angle()
			var line_start := center_pos + Vector2(cos(angle), sin(angle)) * 10
			var line_end := stick_pos - Vector2(cos(angle), sin(angle)) * 25
			draw_line(line_start, line_end, Color(1, 1, 1, 0.5), 2.0)

# Get current direction (useful for polling instead of signals)
func get_direction() -> Vector2:
	if not is_active:
		return Vector2.ZERO

	var direction := current_pos - center_pos
	if direction.length() > max_distance:
		direction = direction.normalized() * max_distance

	var normalized_direction := direction / max_distance

	if normalized_direction.length() < deadzone:
		return Vector2.ZERO

	return normalized_direction
