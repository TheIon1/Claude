extends Camera3D
## Improved camera with independent rotation control
## Supports both mouse (desktop) and touch (mobile) input

# Camera distance settings
@export var min_distance := 0.5
@export var max_distance := 3.0
@export var angle_v_adjust := 0.0

# Camera rotation settings
@export var mouse_sensitivity := 0.003  # Adjust for mouse speed
@export var touch_sensitivity := 0.005  # Adjust for touch speed
@export var rotation_speed := 2.0      # Smooth rotation speed
@export var min_vertical_angle := -80.0  # Degrees
@export var max_vertical_angle := 80.0   # Degrees

# Camera rotation state
var rotation_h := 0.0  # Horizontal rotation (around Y axis)
var rotation_v := 20.0 # Vertical rotation (up/down angle)
var collision_exception := []
var max_height := 2.0
var min_height := 0

@onready var target_node: Node3D = get_parent()

func _ready() -> void:
	collision_exception.append(target_node.get_parent().get_rid())
	# Detaches the camera transform from the parent spatial node
	top_level = true

	# Capture mouse for desktop (comment out for mobile)
	# Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	# Handle mouse movement for camera rotation (Desktop)
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			rotation_h -= event.relative.x * mouse_sensitivity
			rotation_v -= event.relative.y * mouse_sensitivity
			rotation_v = clamp(rotation_v, deg_to_rad(min_vertical_angle), deg_to_rad(max_vertical_angle))

	# Handle touch drag for camera rotation (Mobile)
	elif event is InputEventScreenDrag:
		# Only rotate camera with 2-finger drag (1 finger is for movement)
		if Input.get_current_cursor_shape() == Input.CURSOR_DRAG:
			rotation_h -= event.relative.x * touch_sensitivity
			rotation_v -= event.relative.y * touch_sensitivity
			rotation_v = clamp(rotation_v, deg_to_rad(min_vertical_angle), deg_to_rad(max_vertical_angle))

	# Toggle mouse capture (for desktop testing)
	if event.is_action_pressed(&"ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	var target_pos := target_node.global_transform.origin

	# Calculate camera position based on rotation angles
	var offset := Vector3()
	offset.x = cos(rotation_v) * sin(rotation_h) * max_distance
	offset.y = sin(rotation_v) * max_distance
	offset.z = cos(rotation_v) * cos(rotation_h) * max_distance

	var desired_camera_pos := target_pos + offset

	# Smoothly interpolate camera position
	var camera_pos := global_transform.origin
	camera_pos = camera_pos.lerp(desired_camera_pos, rotation_speed * delta)

	# Apply height constraints
	var delta_pos := camera_pos - target_pos
	if delta_pos.y > max_height:
		delta_pos.y = max_height
		camera_pos = target_pos + delta_pos
	if delta_pos.y < min_height:
		delta_pos.y = min_height
		camera_pos = target_pos + delta_pos

	# Apply distance constraints
	var distance := camera_pos.distance_to(target_pos)
	if distance < min_distance:
		camera_pos = target_pos + (camera_pos - target_pos).normalized() * min_distance

	# Update camera transform
	look_at_from_position(camera_pos, target_pos, Vector3.UP)

	# Apply vertical angle adjustment
	var t := transform
	t.basis = Basis(t.basis[0], deg_to_rad(angle_v_adjust)) * t.basis
	transform = t

# Get camera forward direction (useful for character movement)
func get_forward_direction() -> Vector3:
	var forward := -transform.basis.z
	forward.y = 0  # Keep movement horizontal
	return forward.normalized()

# Get camera right direction (useful for character movement)
func get_right_direction() -> Vector3:
	var right := transform.basis.x
	right.y = 0  # Keep movement horizontal
	return right.normalized()
