extends Node
## Orbital mechanics system - Scene orbits around the sun
## Gravity and physics change based on orbital position

# Orbital settings
@export var orbit_radius := 10.0  # Distance from sun (affects gravity strength)
@export var orbit_speed := 0.1  # Speed of orbit around sun (radians per second)
@export var orbit_angle := 0.0  # Current angle in orbit (0-2π)

# Moon settings
@export var moon_orbit_radius := 15.0  # Moon's orbital distance
@export var moon_orbit_speed := 0.15  # Moon orbits faster
@export var moon_angle := PI  # Moon starts opposite to us
@export var moon_size := 2.0  # Moon radius (for eclipse calculation)

# Gravity settings
@export var base_gravity := 9.8  # Base gravity when at orbit_radius
@export var gravity_strength_multiplier := 1.0  # How much distance affects gravity
@export var eclipse_gravity_reduction := 0.3  # Gravity reduction during eclipse (0-1)

# Light settings during eclipse
@export var eclipse_light_reduction := 0.7  # How much to dim during eclipse (0-1)

# References
var sun_light: DirectionalLight3D = null
var world_environment: WorldEnvironment = null
var original_light_energy := 1.3

# State
var current_gravity_multiplier := 1.0
var is_eclipsed := false
var eclipse_amount := 0.0  # 0 = no eclipse, 1 = total eclipse

func _ready() -> void:
	# Find the sun light
	sun_light = get_tree().root.find_child("DirectionalLight3D", true, false)
	if sun_light:
		original_light_energy = sun_light.light_energy
		print("✓ Orbital System: Sun light found")

	# Find world environment
	world_environment = get_tree().root.find_child("WorldEnvironment", true, false)

	print("✓ Orbital System: Initialized")
	print("  Orbit radius: %.1f, Gravity: %.1f" % [orbit_radius, base_gravity])

func _process(delta: float) -> void:
	# Update orbital position
	orbit_angle += orbit_speed * delta
	if orbit_angle >= TAU:
		orbit_angle -= TAU

	# Update moon position
	moon_angle += moon_orbit_speed * delta
	if moon_angle >= TAU:
		moon_angle -= TAU

	# Calculate distance to sun (changes if orbit is elliptical, but we use circular for now)
	var distance_to_sun := orbit_radius

	# Calculate gravity based on inverse square law (simplified)
	# F = G * M * m / r²
	# Gravity multiplier = (base_radius / current_radius)²
	current_gravity_multiplier = pow(orbit_radius / distance_to_sun, 2.0) * gravity_strength_multiplier

	# Check for eclipse (is moon between us and sun?)
	check_eclipse()

	# Apply eclipse effects
	if sun_light and is_eclipsed:
		# Dim the light during eclipse
		var target_energy := original_light_energy * (1.0 - eclipse_amount * eclipse_light_reduction)
		sun_light.light_energy = lerpf(sun_light.light_energy, target_energy, delta * 2.0)
	elif sun_light:
		# Restore normal light
		sun_light.light_energy = lerpf(sun_light.light_energy, original_light_energy, delta * 2.0)

func check_eclipse() -> void:
	# Calculate positions
	# Our position relative to sun
	var our_pos := Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_radius

	# Moon position relative to sun
	var moon_pos := Vector2(cos(moon_angle), sin(moon_angle)) * moon_orbit_radius

	# Vector from us to sun
	var to_sun := -our_pos

	# Vector from us to moon
	var to_moon := moon_pos - our_pos

	# Check if moon is between us and sun
	# Moon blocks sun if it's in the direction of the sun and close enough
	var angle_to_sun := to_sun.angle()
	var angle_to_moon := to_moon.angle()
	var angle_diff := abs(angle_to_sun - angle_to_moon)
	if angle_diff > PI:
		angle_diff = TAU - angle_diff

	# Calculate angular size of moon from our perspective
	var moon_distance := to_moon.length()
	var angular_size := atan2(moon_size, moon_distance)

	# Eclipse occurs if moon is in sun's direction and covers it
	is_eclipsed = angle_diff < angular_size * 2.0 and moon_distance < to_sun.length()

	if is_eclipsed:
		# Calculate how much of sun is covered
		eclipse_amount = 1.0 - (angle_diff / (angular_size * 2.0))
		eclipse_amount = clampf(eclipse_amount, 0.0, 1.0)
	else:
		eclipse_amount = 0.0

func get_gravity() -> float:
	"""Get current gravity value"""
	var gravity := base_gravity * current_gravity_multiplier

	# Reduce gravity during eclipse (moon's gravity helps us?)
	if is_eclipsed:
		gravity *= (1.0 - eclipse_amount * eclipse_gravity_reduction)

	return gravity

func get_gravity_direction() -> Vector3:
	"""Get direction of gravity pull (toward sun)"""
	# In 3D space, sun is at origin, we orbit in XZ plane
	var our_pos_3d := Vector3(cos(orbit_angle) * orbit_radius, 0, sin(orbit_angle) * orbit_radius)
	var to_sun := -our_pos_3d.normalized()

	# Gravity pulls toward sun, but mostly downward in our local space
	# Blend between pure down and toward sun based on how far we are
	var down := Vector3.DOWN
	var blend := clampf(orbit_radius / 20.0, 0.0, 1.0)
	return down.lerp(to_sun, blend * 0.2).normalized()  # Mostly down, slightly toward sun

func get_orbital_position() -> Vector2:
	"""Get our current position in orbit (for compass/UI)"""
	return Vector2(cos(orbit_angle) * orbit_radius, sin(orbit_angle) * orbit_radius)

func get_sun_direction_orbital() -> Vector2:
	"""Get direction to sun from our orbital position"""
	var our_pos := Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_radius
	return -our_pos.normalized()

func get_moon_direction_orbital() -> Vector2:
	"""Get direction to moon from our orbital position"""
	var our_pos := Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_radius
	var moon_pos := Vector2(cos(moon_angle), sin(moon_angle)) * moon_orbit_radius
	return (moon_pos - our_pos).normalized()

func get_distance_to_sun() -> float:
	"""Get current distance to sun"""
	return orbit_radius

func get_eclipse_info() -> Dictionary:
	"""Get information about current eclipse state"""
	return {
		"is_eclipsed": is_eclipsed,
		"eclipse_amount": eclipse_amount,
		"moon_angle": moon_angle,
		"moon_distance": moon_orbit_radius
	}

# Debug keyboard controls
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F1:
				orbit_speed = clampf(orbit_speed * 2.0, 0.01, 10.0)
				print("Orbital: Orbit speed %.2fx" % orbit_speed)
			KEY_F2:
				orbit_speed = clampf(orbit_speed / 2.0, 0.01, 10.0)
				print("Orbital: Orbit speed %.2fx" % orbit_speed)
			KEY_F3:
				moon_orbit_speed = clampf(moon_orbit_speed * 2.0, 0.01, 10.0)
				print("Orbital: Moon speed %.2fx" % moon_orbit_speed)
			KEY_F4:
				moon_orbit_speed = clampf(moon_orbit_speed / 2.0, 0.01, 10.0)
				print("Orbital: Moon speed %.2fx" % moon_orbit_speed)
			KEY_F5:
				print("═══ ORBITAL STATUS ═══")
				print("Orbit angle: %.1f° (%.1f rad)" % [rad_to_deg(orbit_angle), orbit_angle])
				print("Moon angle: %.1f° (%.1f rad)" % [rad_to_deg(moon_angle), moon_angle])
				print("Distance to sun: %.1f" % get_distance_to_sun())
				print("Gravity: %.2f (multiplier: %.2f)" % [get_gravity(), current_gravity_multiplier])
				print("Eclipse: %s (%.1f%%)" % ["YES" if is_eclipsed else "NO", eclipse_amount * 100])
