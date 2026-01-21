extends Control
## Visual direction indicator showing where the character is moving
## Displays an arrow on screen pointing in the movement direction

@export var indicator_size := 100.0
@export var arrow_color := Color(1.0, 1.0, 0.0, 0.8)  # Yellow with transparency
@export var arrow_outline_color := Color(0.0, 0.0, 0.0, 0.8)  # Black outline
@export var show_compass := true
@export var compass_offset := Vector2(80, 80)  # Distance from screen edge

var character_body: CharacterBody3D = null
var camera: Camera3D = null

func _ready() -> void:
	# Find the character and camera in the scene
	# Adjust the path based on your scene structure
	var player = get_tree().get_first_node_in_group("player")
	if player:
		character_body = player
		camera = player.get_node_or_null("Target/Camera3D")

	# Make sure this Control fills the screen
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _process(_delta: float) -> void:
	queue_redraw()  # Request redraw every frame

func _draw() -> void:
	if not character_body or not camera:
		return

	# Get character velocity (movement direction)
	var velocity := character_body.velocity
	var horizontal_velocity := Vector2(velocity.x, velocity.z)

	# Only draw if character is moving
	if horizontal_velocity.length() > 0.1:
		draw_movement_arrow(horizontal_velocity)

	# Draw compass if enabled
	if show_compass:
		draw_compass()

func draw_movement_arrow(velocity_2d: Vector2) -> void:
	# Get screen center
	var screen_center := size / 2.0

	# Calculate arrow direction (from camera perspective)
	var camera_forward := Vector2(-camera.global_transform.basis.z.x, -camera.global_transform.basis.z.z)
	var camera_right := Vector2(camera.global_transform.basis.x.x, camera.global_transform.basis.x.z)

	# Project velocity onto camera space
	var angle := velocity_2d.angle() - camera_forward.angle()

	# Arrow position (bottom center of screen)
	var arrow_pos := Vector2(screen_center.x, size.y - 120)

	# Draw arrow pointing in movement direction
	var arrow_length := 40.0
	var arrow_width := 15.0

	# Calculate arrow points
	var arrow_tip := arrow_pos + Vector2(cos(angle), sin(angle)) * arrow_length
	var arrow_left := arrow_pos + Vector2(cos(angle + 2.8), sin(angle + 2.8)) * (arrow_length * 0.6)
	var arrow_right := arrow_pos + Vector2(cos(angle - 2.8), sin(angle - 2.8)) * (arrow_length * 0.6)

	# Draw arrow outline
	var outline_points := PackedVector2Array([arrow_tip, arrow_left, arrow_pos, arrow_right, arrow_tip])
	draw_polyline(outline_points, arrow_outline_color, 4.0)

	# Draw arrow fill
	draw_colored_polygon(PackedVector2Array([arrow_tip, arrow_left, arrow_pos]), arrow_color)
	draw_colored_polygon(PackedVector2Array([arrow_tip, arrow_right, arrow_pos]), arrow_color)

	# Draw circle at base
	draw_circle(arrow_pos, 8.0, arrow_outline_color)
	draw_circle(arrow_pos, 6.0, arrow_color)

func draw_compass() -> void:
	if not camera:
		return

	# Compass position (top-right corner)
	var compass_pos := Vector2(size.x - compass_offset.x, compass_offset.y)
	var compass_radius := 50.0

	# Draw compass background
	draw_circle(compass_pos, compass_radius, Color(0.2, 0.2, 0.2, 0.6))
	draw_arc(compass_pos, compass_radius, 0, TAU, 32, Color(1, 1, 1, 0.8), 2.0)

	# Get camera forward direction
	var camera_forward := -camera.global_transform.basis.z
	var north_angle := Vector2(camera_forward.x, camera_forward.z).angle() - PI / 2

	# Draw cardinal directions
	draw_cardinal_direction(compass_pos, compass_radius * 0.7, north_angle, "N", Color(1, 0, 0, 0.9))
	draw_cardinal_direction(compass_pos, compass_radius * 0.7, north_angle + PI/2, "E", Color(1, 1, 1, 0.7))
	draw_cardinal_direction(compass_pos, compass_radius * 0.7, north_angle + PI, "S", Color(1, 1, 1, 0.7))
	draw_cardinal_direction(compass_pos, compass_radius * 0.7, north_angle - PI/2, "W", Color(1, 1, 1, 0.7))

	# Draw north arrow
	var north_point := compass_pos + Vector2(cos(north_angle), sin(north_angle)) * (compass_radius * 0.6)
	draw_line(compass_pos, north_point, Color(1, 0, 0, 0.9), 3.0)

	# Draw arrow head for north
	var arrow_size := 8.0
	var arrow_left := north_point + Vector2(cos(north_angle + 2.8), sin(north_angle + 2.8)) * arrow_size
	var arrow_right := north_point + Vector2(cos(north_angle - 2.8), sin(north_angle - 2.8)) * arrow_size
	draw_colored_polygon(PackedVector2Array([north_point, arrow_left, arrow_right]), Color(1, 0, 0, 0.9))

func draw_cardinal_direction(center: Vector2, radius: float, angle: float, text: String, color: Color) -> void:
	var pos := center + Vector2(cos(angle), sin(angle)) * radius

	# Note: For text rendering, you'll need to use a Label node or load a font
	# This is a simplified version - for production, consider using Label nodes
	draw_circle(pos, 3.0, color)
