# Godot 3D Camera & Character Movement Guide

## Current Setup Analysis

### How It Works Now:
1. **Character Movement** (`cubio.gd`):
   - Character moves with WASD/Arrow keys
   - Movement direction is **relative to camera orientation** (line 31-33)
   - Camera is referenced at line 8: `$Target/Camera3D`

2. **Camera System** (`follow_camera.gd`):
   - Camera **automatically follows** the character
   - Maintains distance between `min_distance` (0.5) and `max_distance` (3.0)
   - Always looks at the character
   - **No independent rotation** - camera is passive

### Scene Hierarchy:
```
Cubio (CharacterBody3D)
├── BoxMesh (visual)
├── CollisionShape3D
└── Target (Node3D) - pivot point at height 0.8
    └── Camera3D (with follow_camera.gd script)
```

---

## Changes Needed for Independent Camera Control

### Option 1: Mouse-Based Camera Rotation (PC/Desktop)

**Key Changes:**
1. Add mouse input to rotate camera around character
2. Keep character movement relative to camera view
3. Add mouse sensitivity settings

**What to modify:**
- `follow_camera.gd`: Add rotation based on mouse movement
- Input: Capture mouse motion events
- Character movement stays the same (already camera-relative)

### Option 2: Touch-Based Camera Rotation (Mobile)

**Key Changes:**
1. Detect touch drag gestures
2. Rotate camera based on touch delta
3. Support multi-touch (one finger moves, two fingers rotate camera)

---

## How to Show Directions on Camera

### Visual Direction Indicators:

#### Option A: On-Screen Arrow/Compass
- UI overlay showing movement direction
- 2D arrow that points where character is moving
- Can show cardinal directions (N, S, E, W)

#### Option B: 3D Direction Indicator
- Visual arrow attached to character
- Shows where character will move
- Color-coded by speed

#### Option C: Minimap/Radar
- Top-down view in corner of screen
- Shows character position and orientation
- Can show nearby objects/objectives

---

## Mobile Rendering Setup (Android, iOS, iPad)

### 1. Export Templates Installation
You need to install export templates in Godot Editor:
- **Editor → Manage Export Templates**
- Download templates for your Godot version

### 2. Android Export Settings

In Godot Editor, go to **Project → Export → Add → Android**:

**Required Settings:**
```
Custom Build: Enabled
Package:
  - Unique Name: com.yourname.kinematiccharacter
  - Name: Kinematic Character
Permissions:
  - Access Network State
  - Internet (if needed)
Screen:
  - Orientation: Landscape (or Sensor for auto-rotation)
```

**Keystore Setup (for release builds):**
- Create keystore using Android Studio or keytool
- Set keystore path, user, and password in export settings

### 3. iOS Export Settings

In Godot Editor, go to **Project → Export → Add → iOS**:

**Required Settings:**
```
App Store Team ID: Your Apple Developer Team ID
Bundle Identifier: com.yourname.kinematiccharacter
Provisioning Profile: Your provisioning profile UUID
Icons: Set all required icon sizes (120x120, 180x180, etc.)
Launch Screens: Configure launch screen storyboard
```

**Requirements:**
- macOS with Xcode installed
- Apple Developer account ($99/year for App Store)
- iOS device or simulator for testing

### 4. Performance Optimizations for Mobile

**Rendering:**
- Use **Mobile** renderer (not Forward+ or Forward Mobile)
- Reduce shadow quality and distance
- Use simpler materials
- Optimize mesh polycount

**In project.godot, add/modify:**
```ini
[rendering]
renderer/rendering_method="mobile"
textures/vram_compression/import_etc2_astc=true
environment/defaults/default_clear_color=Color(0.3, 0.5, 0.8, 1)
anti_aliasing/quality/msaa_3d=2
```

**Physics:**
- Keep physics objects minimal
- Use simple collision shapes (boxes, spheres)
- Limit physics iterations

### 5. Touch Controls

**For mobile, modify input in `project.godot`:**
- Add touch screen button overlays
- Implement virtual joystick
- Add touch areas for camera rotation
- Consider on-screen jump button

---

## Implementation Priority

### Phase 1: Basic Independent Camera
1. ✅ Understand current system (DONE)
2. Modify `follow_camera.gd` for mouse rotation
3. Test camera rotation while character moves
4. Add sensitivity settings

### Phase 2: Direction Indicators
1. Add UI layer for direction arrow
2. Calculate movement direction vector
3. Draw arrow pointing in movement direction
4. Add compass for cardinal directions

### Phase 3: Mobile Support
1. Set up Android export preset
2. Set up iOS export preset (if on macOS)
3. Add touch controls
4. Optimize for mobile performance
5. Test on physical devices

---

## Key Code Locations

- **Character Controller**: `godot_kinematic_character/player/cubio.gd`
- **Camera Controller**: `godot_kinematic_character/player/follow_camera.gd`
- **Scene Setup**: `godot_kinematic_character/player/cubio.tscn`
- **Project Settings**: `godot_kinematic_character/project.godot`
- **Level/Testing**: `godot_kinematic_character/level.tscn`

---

## Next Steps

I'll create modified versions of the scripts with:
1. **Mouse-based camera rotation** (desktop)
2. **Touch-based camera rotation** (mobile)
3. **Direction indicator UI**
4. **Mobile export configuration**

Would you like me to implement these changes now?
