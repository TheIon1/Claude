extends DirectionalLight3D
## Realistic 24-hour day/night cycle with moving sun
## This script controls the DirectionalLight3D node it's attached to

# Time settings
@export var cycle_duration_seconds := 120.0  # Real seconds for full 24h cycle (2 minutes default)
@export var start_time := 6.0  # Start at 6:00 AM (sunrise)
@export var time_scale := 1.0  # Speed multiplier (1.0 = normal, 2.0 = 2x speed)
@export var paused := false

# Sun path settings
@export var sun_latitude := 45.0  # Degrees (affects sun arc height)
@export var sun_east_direction := 90.0  # Degrees (which direction is east)

# Light intensity settings
@export var day_intensity := 1.3
@export var night_intensity := 0.1
@export var sunrise_sunset_intensity := 0.6

# Light color settings
@export var day_color := Color(1.0, 1.0, 1.0, 1.0)  # White
@export var sunrise_color := Color(1.0, 0.6, 0.3, 1.0)  # Orange
@export var sunset_color := Color(1.0, 0.4, 0.2, 1.0)  # Deep orange/red
@export var night_color := Color(0.4, 0.5, 0.8, 1.0)  # Bluish

# Current time (0-24 hours)
var current_time := 6.0

# References
@onready var directional_light: DirectionalLight3D = self

func _ready() -> void:
	current_time = start_time
	update_sun_position()
	print("Day/Night Cycle: Started at %.1f:00 (%.0f sec = 24h)" % [current_time, cycle_duration_seconds])

func _process(delta: float) -> void:
	if paused:
		return

	# Advance time
	var hours_per_second := 24.0 / cycle_duration_seconds
	current_time += delta * hours_per_second * time_scale

	# Wrap around at 24 hours
	if current_time >= 24.0:
		current_time -= 24.0

	# Update sun position and lighting
	update_sun_position()

func update_sun_position() -> void:
	# Convert time to angle (0-360 degrees, where 0 = midnight)
	var time_angle := (current_time / 24.0) * 360.0

	# Calculate sun position
	# At 6:00 (sunrise): Sun at horizon in east (90°)
	# At 12:00 (noon): Sun directly overhead
	# At 18:00 (sunset): Sun at horizon in west (270°)
	# At 0:00 (midnight): Sun below horizon in north

	# Vertical angle (elevation)
	# 0° at midnight, 90° at noon, 0° at midnight again
	var elevation := -cos(deg_to_rad(time_angle)) * 90.0

	# Horizontal angle (azimuth) - sun moves east to west
	# Add sun_east_direction offset to align with world directions
	var azimuth := time_angle + sun_east_direction - 90.0

	# Convert to rotation
	# Pitch (X rotation): elevation angle
	# Yaw (Y rotation): azimuth angle
	var pitch := deg_to_rad(-elevation)  # Negative because Godot's X rotation
	var yaw := deg_to_rad(azimuth)

	# Apply rotation (sun direction)
	rotation.x = pitch
	rotation.y = yaw
	rotation.z = 0

	# Update light intensity and color based on time of day
	update_light_properties()

func update_light_properties() -> void:
	var time_of_day := get_time_of_day()

	match time_of_day:
		"night":
			directional_light.light_energy = night_intensity
			directional_light.light_color = night_color
		"sunrise":
			var sunrise_progress := (current_time - 5.0) / 2.0  # 5-7 AM
			directional_light.light_energy = lerpf(night_intensity, day_intensity, sunrise_progress)
			directional_light.light_color = night_color.lerp(sunrise_color, sunrise_progress)
		"day":
			directional_light.light_energy = day_intensity
			directional_light.light_color = day_color
		"sunset":
			var sunset_progress := (current_time - 17.0) / 2.0  # 5-7 PM
			directional_light.light_energy = lerpf(day_intensity, night_intensity, sunset_progress)
			directional_light.light_color = day_color.lerp(sunset_color, sunset_progress)

func get_time_of_day() -> String:
	if current_time >= 5.0 and current_time < 7.0:
		return "sunrise"
	elif current_time >= 7.0 and current_time < 17.0:
		return "day"
	elif current_time >= 17.0 and current_time < 19.0:
		return "sunset"
	else:
		return "night"

func get_sun_direction() -> Vector3:
	# Returns the direction the sun is shining (normalized vector)
	return -global_transform.basis.z

func get_sun_azimuth() -> float:
	# Returns sun's horizontal angle in degrees (0 = North, 90 = East, 180 = South, 270 = West)
	var sun_dir := get_sun_direction()
	var azimuth := atan2(sun_dir.x, -sun_dir.z)
	return rad_to_deg(azimuth)

func get_sun_elevation() -> float:
	# Returns sun's vertical angle in degrees (0 = horizon, 90 = zenith, negative = below horizon)
	var sun_dir := get_sun_direction()
	return rad_to_deg(asin(sun_dir.y))

func get_time_string() -> String:
	var hours := int(current_time)
	var minutes := int((current_time - hours) * 60)
	return "%02d:%02d" % [hours, minutes]

func set_time(hour: float) -> void:
	current_time = clamp(hour, 0.0, 24.0)
	update_sun_position()

func skip_to_time(hour: float) -> void:
	set_time(hour)

# Keyboard shortcuts for testing
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_page_up"):
		time_scale = clamp(time_scale * 2.0, 0.1, 100.0)
		print("Day/Night: Time speed %.1fx" % time_scale)
	elif event.is_action_pressed("ui_page_down"):
		time_scale = clamp(time_scale / 2.0, 0.1, 100.0)
		print("Day/Night: Time speed %.1fx" % time_scale)
	elif event.is_action_pressed("ui_home"):
		paused = !paused
		print("Day/Night: %s" % ("PAUSED" if paused else "RESUMED"))

	# Quick time jumps for testing
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				skip_to_time(6.0)  # Sunrise
				print("Day/Night: Jumped to 06:00 (sunrise)")
			KEY_2:
				skip_to_time(12.0)  # Noon
				print("Day/Night: Jumped to 12:00 (noon)")
			KEY_3:
				skip_to_time(18.0)  # Sunset
				print("Day/Night: Jumped to 18:00 (sunset)")
			KEY_4:
				skip_to_time(0.0)  # Midnight
				print("Day/Night: Jumped to 00:00 (midnight)")
