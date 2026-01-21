extends Control
## Visual direction indicator showing where the character is moving
## Displays an arrow on screen pointing in the movement direction

@export var indicator_size := 100.0
@export var arrow_color := Color(1.0, 1.0, 0.0, 0.8)  # Yellow with transparency
@export var arrow_outline_color := Color(0.0, 0.0, 0.0, 0.8)  # Black outline
@export var show_compass := true
@export var show_sun := true  # Show sun position on compass
@export var show_time := true  # Show current time
@export var compass_offset := Vector2(80, 80)  # Distance from screen edge
@export var show_debug := false  # Show debug info

var character_body: CharacterBody3D = null
var camera: Camera3D = null
var sun_light: DirectionalLight3D = null
var day_night_cycle = null

func _ready() -> void:
	# Find the character and camera in the scene
	var player = get_tree().get_first_node_in_group("player")
	if player:
		character_body = player
		camera = player.get_node_or_null("Target/Camera3D")
		print("✓ Direction Indicator: Found player in 'player' group")
	else:
		# Try alternate method - find by name
		player = get_tree().root.find_child("Cubio", true, false)
		if player:
			character_body = player
			camera = player.get_node_or_null("Target/Camera3D")
			print("✓ Direction Indicator: Found player by name 'Cubio'")
		else:
			print("✗ Direction Indicator: WARNING - Could not find player!")
			print("  Make sure 'Cubio' node exists or add it to 'player' group")

	if camera:
		print("✓ Direction Indicator: Camera found")
	else:
		print("✗ Direction Indicator: Camera NOT found!")

	# Find the sun (DirectionalLight3D)
	sun_light = get_tree().root.find_child("DirectionalLight3D", true, false)
	if sun_light:
		print("✓ Direction Indicator: Sun/DirectionalLight3D found")
		# Check if it has the day/night cycle script
		if sun_light.has_method("get_time_string"):
			day_night_cycle = sun_light
			print("✓ Direction Indicator: Day/night cycle active")
	else:
		print("⚠ Direction Indicator: No DirectionalLight3D found (sun compass disabled)")

	# Make sure this Control fills the screen
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	print("✓ Direction Indicator: Setup complete, size:", size)

func _process(_delta: float) -> void:
	queue_redraw()  # Request redraw every frame

func _draw() -> void:
	# Always draw something to verify the Control is working
	if show_debug:
		draw_circle(Vector2(50, 50), 10, Color.RED)  # Debug marker
		draw_string(ThemeDB.fallback_font, Vector2(70, 55), "DirectionIndicator Active", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)

	if not character_body or not camera:
		# Draw error message if player/camera not found
		var error_pos := Vector2(size.x / 2, size.y / 2)
		draw_string(ThemeDB.fallback_font, error_pos, "Waiting for player...", HORIZONTAL_ALIGNMENT_CENTER, -1, 20, Color.RED)
		return

	# Draw compass first (always visible)
	if show_compass:
		draw_compass()

	# Get character velocity (movement direction)
	var velocity := character_body.velocity
	var horizontal_velocity := Vector2(velocity.x, velocity.z)

	# Only draw arrow if character is moving
	if horizontal_velocity.length() > 0.1:
		draw_movement_arrow(horizontal_velocity)
	elif show_debug:
		# Show "not moving" indicator
		var msg_pos := Vector2(size.x / 2, size.y - 100)
		draw_string(ThemeDB.fallback_font, msg_pos, "Stand still (no arrow)", HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color.YELLOW)

func draw_movement_arrow(velocity_2d: Vector2) -> void:
	# Get screen center
	var screen_center := size / 2.0

	# Get camera's forward and right vectors in world space (XZ plane)
	var cam_transform := camera.global_transform
	var camera_forward := Vector2(-cam_transform.basis.z.x, -cam_transform.basis.z.z).normalized()
	var camera_right := Vector2(cam_transform.basis.x.x, cam_transform.basis.x.z).normalized()

	# Project velocity onto camera axes
	var forward_amount := velocity_2d.dot(camera_forward)
	var right_amount := velocity_2d.dot(camera_right)

	# Calculate screen angle for the arrow
	# Forward (W) should point up on screen = angle -PI/2
	# Right (D) should point right on screen = angle 0
	# Screen Y points down, so up is negative Y
	var screen_angle := atan2(-forward_amount, right_amount)

	# Arrow position (bottom center of screen)
	var arrow_pos := Vector2(screen_center.x, size.y - 120)

	# Arrow dimensions
	var arrow_length := 50.0
	var arrow_head_angle := 2.5  # Angle for arrow head wings

	# Calculate arrow tip and wings
	var arrow_tip := arrow_pos + Vector2(cos(screen_angle), sin(screen_angle)) * arrow_length
	var arrow_left := arrow_pos + Vector2(cos(screen_angle + arrow_head_angle), sin(screen_angle + arrow_head_angle)) * (arrow_length * 0.6)
	var arrow_right := arrow_pos + Vector2(cos(screen_angle - arrow_head_angle), sin(screen_angle - arrow_head_angle)) * (arrow_length * 0.6)

	# Draw arrow outline (thicker)
	var outline_points := PackedVector2Array([arrow_tip, arrow_left, arrow_pos, arrow_right, arrow_tip])
	draw_polyline(outline_points, arrow_outline_color, 5.0, true)

	# Draw arrow fill
	var arrow_triangle := PackedVector2Array([arrow_tip, arrow_left, arrow_right])
	draw_colored_polygon(arrow_triangle, arrow_color)

	# Draw shaft
	var shaft_width := 12.0
	var shaft_points := PackedVector2Array([
		arrow_pos + Vector2(-shaft_width/2, 0),
		arrow_pos + Vector2(shaft_width/2, 0),
		arrow_left,
		arrow_right
	])
	draw_colored_polygon(shaft_points, arrow_color)

	# Draw circle at base
	draw_circle(arrow_pos, 10.0, arrow_outline_color)
	draw_circle(arrow_pos, 8.0, arrow_color)

	# Debug info
	if show_debug:
		var debug_pos := arrow_pos + Vector2(0, 40)
		var angle_deg := rad_to_deg(screen_angle)
		# Normalize to 0-360 range for easier reading
		if angle_deg < 0:
			angle_deg += 360
		draw_string(ThemeDB.fallback_font, debug_pos, "Angle: %.1f° (↑=-90°/270°)", HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color.WHITE)

		# Show velocity components
		var debug_pos2 := arrow_pos + Vector2(0, 60)
		var fwd := velocity_2d.dot(Vector2(-camera.global_transform.basis.z.x, -camera.global_transform.basis.z.z).normalized())
		var rgt := velocity_2d.dot(Vector2(camera.global_transform.basis.x.x, camera.global_transform.basis.x.z).normalized())
		draw_string(ThemeDB.fallback_font, debug_pos2, "Fwd:%.1f Right:%.1f" % [fwd, rgt], HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color.WHITE)

func draw_compass() -> void:
	if not camera:
		return

	# Compass position (top-right corner)
	var compass_pos := Vector2(size.x - compass_offset.x, compass_offset.y)
	var compass_radius := 50.0

	# Draw compass background circle
	draw_circle(compass_pos, compass_radius, Color(0.2, 0.2, 0.2, 0.7))
	draw_arc(compass_pos, compass_radius, 0, TAU, 32, Color(1, 1, 1, 0.9), 2.5)

	# Define north in world space (negative Z direction in Godot)
	var north_world := Vector2(0, -1)  # North in XZ plane

	# Get camera axes in XZ plane
	var cam_transform := camera.global_transform
	var camera_fwd_xz := Vector2(-cam_transform.basis.z.x, -cam_transform.basis.z.z).normalized()
	var camera_right_xz := Vector2(cam_transform.basis.x.x, cam_transform.basis.x.z).normalized()

	# Project north direction onto camera axes (where is north relative to camera?)
	var north_forward := north_world.dot(camera_fwd_xz)  # How much north is ahead
	var north_right := north_world.dot(camera_right_xz)  # How much north is to the right

	# Calculate screen angle for north (same method as arrow)
	# This tells us which direction to draw the north arrow on the compass
	var north_angle := atan2(-north_forward, north_right)

	# Draw cardinal direction markers
	for i in range(4):
		var cardinal_angle := north_angle + (i * PI / 2)
		var marker_pos := compass_pos + Vector2(cos(cardinal_angle), sin(cardinal_angle)) * (compass_radius * 0.75)
		var marker_color := Color(1, 0, 0, 0.95) if i == 0 else Color(1, 1, 1, 0.8)
		draw_circle(marker_pos, 4.0, marker_color)

	# Draw north indicator (red arrow)
	var north_start := compass_pos
	var north_end := compass_pos + Vector2(cos(north_angle), sin(north_angle)) * (compass_radius * 0.65)
	draw_line(north_start, north_end, Color(1, 0, 0, 0.95), 4.0)

	# Draw north arrow head
	var arrow_size := 10.0
	var head_angle_offset := 2.5
	var arrow_tip := north_end
	var arrow_left := north_end - Vector2(cos(north_angle - head_angle_offset), sin(north_angle - head_angle_offset)) * arrow_size
	var arrow_right := north_end - Vector2(cos(north_angle + head_angle_offset), sin(north_angle + head_angle_offset)) * arrow_size
	draw_colored_polygon(PackedVector2Array([arrow_tip, arrow_left, arrow_right]), Color(1, 0, 0, 0.95))

	# Draw sun position (if enabled and sun exists)
	if show_sun and sun_light:
		draw_sun_on_compass(compass_pos, compass_radius, camera_fwd_xz, camera_right_xz)

	# Draw time display (if enabled)
	if show_time and day_night_cycle:
		var time_str: String = day_night_cycle.get_time_string()
		var time_of_day: String = day_night_cycle.get_time_of_day()
		var time_pos := compass_pos + Vector2(0, compass_radius + 50)
		var time_color := Color.WHITE
		match time_of_day:
			"sunrise":
				time_color = Color(1.0, 0.7, 0.3)
			"day":
				time_color = Color(1.0, 1.0, 0.6)
			"sunset":
				time_color = Color(1.0, 0.5, 0.2)
			"night":
				time_color = Color(0.6, 0.7, 1.0)
		draw_string(ThemeDB.fallback_font, time_pos, time_str, HORIZONTAL_ALIGNMENT_CENTER, -1, 16, time_color)

	# Draw center dot
	draw_circle(compass_pos, 5.0, Color(0.5, 0.5, 0.5, 0.9))
	draw_circle(compass_pos, 3.0, Color(1, 1, 1, 0.9))

	# Optional: Draw N/S/E/W labels (using circles as placeholders)
	# For actual text, you'd need to use Label nodes or draw_string with a font
	if show_debug:
		var compass_angle_deg := rad_to_deg(north_angle)
		if compass_angle_deg < 0:
			compass_angle_deg += 360
		draw_string(ThemeDB.fallback_font, compass_pos + Vector2(0, compass_radius + 15), "N@%.0f°" % compass_angle_deg, HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color.RED)

		# Show what direction camera is facing in world
		# Negate both X and Z to get correct angles: North=0°, East=90°, South=180°, West=270°
		var camera_world_angle := atan2(-camera_fwd_xz.x, -camera_fwd_xz.y)
		var camera_deg := rad_to_deg(camera_world_angle)
		if camera_deg < 0:
			camera_deg += 360
		var dir_name := ""
		if camera_deg < 45 or camera_deg >= 315:
			dir_name = "N"
		elif camera_deg < 135:
			dir_name = "E"
		elif camera_deg < 225:
			dir_name = "S"
		else:
			dir_name = "W"
		draw_string(ThemeDB.fallback_font, compass_pos + Vector2(0, compass_radius + 30), "Cam:%s(%.0f°)" % [dir_name, camera_deg], HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color.WHITE)

func draw_sun_on_compass(compass_pos: Vector2, compass_radius: float, camera_fwd_xz: Vector2, camera_right_xz: Vector2) -> void:
	# Get sun direction in world space
	# Light's -Z axis points where light SHINES TO, so negate to get where sun IS
	var sun_dir_3d := sun_light.global_transform.basis.z  # Direction FROM sun (opposite of light direction)
	var sun_horizontal := Vector2(sun_dir_3d.x, sun_dir_3d.z).normalized()
	var sun_elevation := sun_dir_3d.y  # How high the sun is (-1 = below horizon, 0 = horizon, 1 = zenith)

	# Project sun direction onto camera axes
	var sun_forward := sun_horizontal.dot(camera_fwd_xz)
	var sun_right := sun_horizontal.dot(camera_right_xz)

	# Calculate screen angle for sun
	var sun_angle := atan2(-sun_forward, sun_right)

	# Only draw sun if it's above horizon
	if sun_elevation > -0.1:  # Small margin to show sun near horizon
		# Sun distance from center (based on elevation)
		# When sun is at zenith (elevation=1), it's at center
		# When sun is at horizon (elevation=0), it's at edge
		var sun_distance := compass_radius * 0.6 * (1.0 - sun_elevation)

		var sun_pos := compass_pos + Vector2(cos(sun_angle), sin(sun_angle)) * sun_distance

		# Sun color based on elevation
		var sun_color := Color.WHITE
		if sun_elevation < 0.3:  # Near horizon
			sun_color = Color(1.0, 0.6, 0.2)  # Orange
		else:
			sun_color = Color(1.0, 1.0, 0.6)  # Bright yellow

		# Draw sun glow
		for i in range(3):
			var glow_size := 12.0 - (i * 3.0)
			var glow_alpha := 0.3 - (i * 0.1)
			draw_circle(sun_pos, glow_size, Color(sun_color.r, sun_color.g, sun_color.b, glow_alpha))

		# Draw sun body
		draw_circle(sun_pos, 6.0, sun_color)
		draw_circle(sun_pos, 5.0, Color(1.0, 1.0, 1.0, 0.9))

		# Draw sun rays
		for i in range(8):
			var ray_angle := sun_angle + (i * TAU / 8.0)
			var ray_start := sun_pos + Vector2(cos(ray_angle), sin(ray_angle)) * 7
			var ray_end := sun_pos + Vector2(cos(ray_angle), sin(ray_angle)) * 12
			draw_line(ray_start, ray_end, sun_color, 2.0)

		# Debug: show sun elevation
		if show_debug and day_night_cycle:
			var elev_angle: float = day_night_cycle.get_sun_elevation()
			var sun_debug_pos := sun_pos + Vector2(0, -20)
			draw_string(ThemeDB.fallback_font, sun_debug_pos, "☀%.0f°" % elev_angle, HORIZONTAL_ALIGNMENT_CENTER, -1, 12, sun_color)
	else:
		# Sun is below horizon - show moon instead
		var moon_pos := compass_pos + Vector2(cos(sun_angle + PI), sin(sun_angle + PI)) * (compass_radius * 0.5)
		draw_circle(moon_pos, 5.0, Color(0.7, 0.7, 0.8, 0.8))
		draw_circle(moon_pos, 4.0, Color(0.9, 0.9, 1.0, 0.9))
		# Moon crescent
		draw_circle(moon_pos + Vector2(2, -1), 4.0, Color(0.2, 0.2, 0.3, 0.5))
