# Direction Indicator Setup Guide

## Quick Fix for Yellow Arrow

The yellow arrow should now point in the direction your character is moving **relative to the camera view**.

### What Was Fixed:
- **Before**: Arrow used absolute world coordinates (didn't match screen direction)
- **After**: Arrow transforms velocity to camera-relative screen space (matches what you see)

### How It Works Now:
- **Move forward** (W) → Arrow points UP
- **Move backward** (S) → Arrow points DOWN
- **Move left** (A) → Arrow points LEFT
- **Move right** (D) → Arrow points RIGHT
- **Move diagonally** → Arrow points at the angle between

The arrow rotates based on **both** the movement direction AND camera rotation, so it always shows where the character is moving on screen.

## Setup Steps (if arrow still not working)

### 1. Add Player to "player" Group

The direction indicator finds the character by looking for a node in the "player" group.

**In Godot Editor:**
1. Open `level.tscn`
2. Select the **Cubio** node (the CharacterBody3D)
3. In the Inspector panel, click the **Node** tab (next to Inspector)
4. Look for the **Groups** section
5. Click **Manage Groups** button
6. Add group name: `player`
7. Click **OK**
8. Save the scene

**Alternative Method:**
The script now also searches by name "Cubio" as a fallback, so it should work even without the group.

### 2. Verify Scene Structure

The direction indicator expects this hierarchy:
```
Cubio (CharacterBody3D) ← should be in "player" group
└── Target (Node3D)
    └── Camera3D
```

If your structure is different, adjust the path in `direction_indicator.gd` line 19:
```gdscript
camera = player.get_node_or_null("Target/Camera3D")
```

### 3. Check Console Output

When you run the game, check the **Output** panel at the bottom of Godot Editor. You should see:
```
Direction Indicator: Found player and camera
```

If you see:
```
Direction Indicator: WARNING - Could not find player!
```
Then the player node isn't being found.

### 4. Verify Direction Indicator is in Scene

Make sure the direction indicator Control node exists:

**In Godot Editor:**
1. Open `level.tscn`
2. Check if there's a **CanvasLayer** node
3. Under it, there should be a **Control** node with the `direction_indicator.gd` script attached
4. Make sure it's **visible** (eye icon should be open)

## Testing the Arrow

Run the game and test:

1. **Stand still** → No arrow (only appears when moving)
2. **Press W** (forward) → Arrow points UP on screen
3. **Rotate camera** with mouse while holding W → Arrow stays pointing UP (forward relative to camera)
4. **Press A** (left) → Arrow points LEFT on screen
5. **Press W+D** (forward+right) → Arrow points diagonally UP-RIGHT

The arrow should always match the direction the character moves **as you see it on screen**.

## Customization

### Arrow Appearance

In `direction_indicator.gd`, you can adjust:

```gdscript
@export var arrow_color := Color(1.0, 1.0, 0.0, 0.8)  # Yellow, semi-transparent
@export var arrow_outline_color := Color(0.0, 0.0, 0.0, 0.8)  # Black outline
```

Try different colors:
- Red: `Color(1.0, 0.0, 0.0, 0.8)`
- Green: `Color(0.0, 1.0, 0.0, 0.8)`
- Blue: `Color(0.0, 0.5, 1.0, 0.8)`
- White: `Color(1.0, 1.0, 1.0, 0.8)`

### Arrow Position

Change line 55 in `direction_indicator.gd`:
```gdscript
var arrow_pos := Vector2(screen_center.x, size.y - 120)  # Bottom center
```

Move it:
- Higher: Increase the subtraction (e.g., `size.y - 200`)
- Lower: Decrease the subtraction (e.g., `size.y - 50`)
- Left: Change `screen_center.x` to `100` (fixed position)
- Right: Change `screen_center.x` to `size.x - 100`

### Arrow Size

Line 58-59:
```gdscript
var arrow_length := 40.0  # Make bigger for longer arrow
var arrow_width := 15.0   # Make bigger for wider arrow head
```

## Troubleshooting

### Arrow shows but doesn't rotate correctly
- ✅ Fixed! The new calculation properly transforms velocity to screen space

### Arrow doesn't appear at all
- Check if character is moving (arrow only shows when velocity > 0.1)
- Verify player is found (check console output)
- Make sure CanvasLayer is visible

### Arrow points in wrong direction
- This should be fixed now with the camera-relative calculation
- If still wrong, check that camera reference is correct

### Arrow is too small/big
- Adjust `arrow_length` and `arrow_width` in the script
- Or change the overall scale at line 58-59

## What the Arrow Shows

The arrow indicates:
- **Direction**: Where the character is currently moving relative to screen
- **Existence**: Only visible when character is actually moving
- **Rotation**: Updates based on both movement input and camera angle

It's useful for:
- Understanding which way you're moving
- Debugging movement issues
- Learning how camera-relative movement works
- Mobile games where virtual joystick might be ambiguous

---

**The arrow should now correctly show your movement direction! Try it out.**
