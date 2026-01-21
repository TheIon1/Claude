# Quick Start Guide - Godot Kinematic Character 3D

## Project Overview

This is a modified version of Godot's kinematic character demo with:
- ✅ **Independent camera and character movement**
- ✅ **Direction indicators (arrow + compass)**
- ✅ **Mobile touch controls**
- ✅ **Mobile export configurations**

---

## File Structure

```
godot_kinematic_character/
├── player/
│   ├── cubio.gd                      # Original character controller
│   ├── follow_camera.gd              # Original camera (auto-follow)
│   ├── follow_camera_improved.gd     # NEW: Mouse/touch camera rotation
│   ├── direction_indicator.gd        # NEW: Movement arrow + compass UI
│   ├── virtual_joystick.gd           # NEW: Touch joystick for mobile
│   └── cubio.tscn                    # Player scene
├── level.tscn                        # Demo level
└── project.godot                     # Project settings

Additional Files:
├── CAMERA_MOVEMENT_GUIDE.md          # Detailed camera/movement explanation
├── MOBILE_EXPORT_GUIDE.md            # Complete mobile export tutorial
└── QUICK_START_GUIDE.md              # This file
```

---

## How to Integrate the New Features

### Step 1: Replace Camera Script

**Option A - In Godot Editor (Recommended):**
1. Open `cubio.tscn` in Godot
2. Select the **Camera3D** node (under Target)
3. In the Inspector, find the **Script** property
4. Click the script icon and choose **Load**
5. Select `follow_camera_improved.gd`
6. Save the scene

**Option B - Manual File Edit:**
1. Rename/backup the old camera script:
   ```bash
   mv player/follow_camera.gd player/follow_camera_original.gd
   ```
2. Rename the improved version:
   ```bash
   mv player/follow_camera_improved.gd player/follow_camera.gd
   ```

### Step 2: Add Direction Indicator UI

**In Godot Editor:**
1. Open `level.tscn`
2. Right-click the root node → **Add Child Node**
3. Search for **CanvasLayer** → Add
4. Right-click CanvasLayer → **Add Child Node**
5. Search for **Control** → Add
6. Name it "DirectionIndicator"
7. In the Inspector:
   - **Layout** → **Full Rect** (anchor preset)
8. Attach script `direction_indicator.gd`:
   - Click **Attach Script** button
   - Select existing script: `player/direction_indicator.gd`
9. In the script, make sure to add player to a group:
   - Select **Cubio** node in the scene
   - In Inspector → **Node** tab → **Groups**
   - Add group name: `player`
10. Save the scene

### Step 3: Add Virtual Joystick (for Mobile)

**In Godot Editor:**
1. Open `level.tscn`
2. Find the **CanvasLayer** you created
3. Right-click CanvasLayer → **Add Child Node**
4. Search for **Control** → Add
5. Name it "VirtualJoystick"
6. In the Inspector:
   - **Transform** → **Position**: (100, 500) or bottom-left area
   - **Transform** → **Size**: (150, 150)
7. Attach script:
   - Click **Attach Script** button
   - Select: `player/virtual_joystick.gd`
8. Save the scene

### Step 4: Update Character Controller for Touch Input

**Edit `player/cubio.gd`:**

Add at the top:
```gdscript
var virtual_joystick: Control = null
var virtual_joystick_direction := Vector2.ZERO
```

In `_ready()` function, add:
```gdscript
func _ready() -> void:
	# Find virtual joystick in the scene
	var joystick = get_tree().get_first_node_in_group("virtual_joystick")
	if joystick:
		virtual_joystick = joystick
		joystick.direction_changed.connect(_on_joystick_direction_changed)
```

Add new function:
```gdscript
func _on_joystick_direction_changed(direction: Vector2) -> void:
	virtual_joystick_direction = direction
```

In `_physics_process()`, replace input reading (around line 25-27):
```gdscript
	var dir := Vector3()

	# Use virtual joystick if active (mobile)
	if virtual_joystick_direction.length() > 0.1:
		dir.x = virtual_joystick_direction.x
		dir.z = virtual_joystick_direction.y
	else:
		# Fallback to keyboard (desktop)
		dir.x = Input.get_axis(&"move_left", &"move_right")
		dir.z = Input.get_axis(&"move_forward", &"move_back")
```

Also, add the joystick to a group:
- Select VirtualJoystick node
- Groups tab → Add "virtual_joystick"

---

## Testing the New Features

### Desktop Testing:

1. **Open project in Godot 4**
2. **Run the project** (F5)
3. **Camera controls:**
   - Move mouse to rotate camera (if mouse capture is enabled)
   - Press **ESC** to toggle mouse capture
4. **Character movement:**
   - **WASD** or **Arrow keys** to move
   - **Space** to jump
5. **Visual indicators:**
   - Yellow arrow at bottom shows movement direction
   - Compass in top-right shows cardinal directions

### Mobile Testing:

1. **Export for Android/iOS** (see MOBILE_EXPORT_GUIDE.md)
2. Install on device
3. **Touch controls:**
   - Drag the virtual joystick (bottom-left) to move
   - Two-finger drag anywhere to rotate camera
   - Tap jump button (if added)

---

## Customization Options

### Camera Settings

In `follow_camera_improved.gd`, you can adjust:
```gdscript
@export var mouse_sensitivity := 0.003    # Mouse rotation speed
@export var touch_sensitivity := 0.005    # Touch rotation speed
@export var rotation_speed := 2.0         # Camera follow smoothness
@export var min_vertical_angle := -80.0   # Look down limit
@export var max_vertical_angle := 80.0    # Look up limit
@export var min_distance := 0.5           # Closest zoom
@export var max_distance := 3.0           # Farthest zoom
```

### Direction Indicator Settings

In `direction_indicator.gd`:
```gdscript
@export var indicator_size := 100.0
@export var arrow_color := Color(1.0, 1.0, 0.0, 0.8)  # Yellow
@export var show_compass := true                       # Toggle compass
@export var compass_offset := Vector2(80, 80)          # Position
```

### Virtual Joystick Settings

In `virtual_joystick.gd`:
```gdscript
@export var max_distance := 60.0          # Joystick range
@export var deadzone := 0.1               # Center deadzone
@export var base_color := Color(1, 1, 1, 0.3)
@export var stick_color := Color(1, 1, 1, 0.8)
```

---

## Mouse Capture for Desktop

By default, mouse capture is **disabled** for easier testing. To enable:

**In `follow_camera_improved.gd`, line 33:**
```gdscript
func _ready() -> void:
	collision_exception.append(target_node.get_parent().get_rid())
	top_level = true

	# Uncomment this line to enable mouse capture on start:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
```

**Controls with mouse capture:**
- Press **ESC** to release mouse
- Move mouse to rotate camera
- Click to capture again

---

## Adding a Jump Button for Mobile

Create a touch button:

1. In `level.tscn`, add a **Button** node under CanvasLayer
2. Position it (bottom-right corner)
3. Set text: "Jump"
4. Connect pressed signal to player script:

```gdscript
# In cubio.gd
func _on_jump_button_pressed() -> void:
	if is_on_floor():
		velocity.y = JUMP_SPEED
```

Or use an on-screen button node:
- **TouchScreenButton** node type
- Set texture (circle or button image)
- Set action: "jump"

---

## Mobile Performance Tips

### 1. Reduce Shadow Quality
In `level.tscn` or main scene:
```gdscript
func _ready():
	if OS.get_name() in ["Android", "iOS"]:
		# Mobile optimization
		get_viewport().msaa_3d = Viewport.MSAA_2X
```

### 2. Use Mobile Renderer
In `project.godot`:
```ini
[rendering]
renderer/rendering_method="mobile"
```

### 3. Simplify Physics
- Use simple collision shapes
- Reduce physics objects
- Lower physics tick rate if needed

---

## Troubleshooting

### Camera Not Rotating
- **Check**: Is mouse capture enabled? (Press ESC)
- **Check**: Is the improved camera script attached?
- **Check**: Are you using 2-finger drag on mobile?

### Direction Indicator Not Showing
- **Check**: Is player in "player" group?
- **Check**: Is Camera3D path correct in script?
- **Check**: Is CanvasLayer visible?

### Virtual Joystick Not Working
- **Check**: Is joystick in "virtual_joystick" group?
- **Check**: Is signal connected to player?
- **Check**: Is touch input enabled in project settings?

### Mobile Build Issues
- See **MOBILE_EXPORT_GUIDE.md** for detailed solutions
- Check Android SDK path
- Verify provisioning profile (iOS)
- Test with debug build first

---

## What's Different from Original Demo

| Feature | Original | Improved |
|---------|----------|----------|
| Camera Control | Auto-follow only | Mouse/touch rotation |
| Movement Direction | Camera-relative | Camera-relative (same) |
| Visual Indicators | None | Arrow + Compass |
| Mobile Support | Keyboard only | Touch joystick |
| Export Configs | Basic | Android + iOS ready |

---

## Next Steps

1. ✅ **Test on desktop** with new camera controls
2. ✅ **Customize** visual indicators and colors
3. ✅ **Add** mobile touch controls
4. ✅ **Export** to Android/iOS
5. ✅ **Test** on physical devices
6. 🎮 **Add** your own game mechanics!

---

## Summary of Key Concepts

### Separate Camera & Character Movement:

**Before:** Camera passively followed character
**After:** Camera rotates independently with mouse/touch, character moves relative to camera view

### Direction Indicators:

- **Movement Arrow**: Shows where character is currently moving
- **Compass**: Shows cardinal directions (N/S/E/W) based on camera orientation
- Both update in real-time

### Mobile Rendering:

- **Android**: APK/AAB build via Godot export
- **iOS**: Xcode project, requires Apple Developer account
- **Touch Controls**: Virtual joystick + camera rotation gestures

---

## Resources

- **Godot Documentation**: https://docs.godotengine.org/
- **Export Tutorial**: See `MOBILE_EXPORT_GUIDE.md`
- **Camera Details**: See `CAMERA_MOVEMENT_GUIDE.md`
- **Godot Forum**: https://forum.godotengine.org/

---

Ready to start developing! Open the project in Godot 4 and begin testing. 🚀
