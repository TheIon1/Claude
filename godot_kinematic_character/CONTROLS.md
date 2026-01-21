# Game Controls

## Desktop Controls

### Mouse & Keyboard:
- **Move Mouse** - Rotate camera around character
- **WASD** or **Arrow Keys** - Move character
- **Space** - Jump
- **ESC** - Release/Capture mouse cursor

### How Mouse Capture Works:
When you start the game, your mouse is **automatically captured** (cursor disappears). This allows you to rotate the camera by moving the mouse.

- **Captured Mode**: Move mouse to rotate camera (cursor hidden)
- **Released Mode**: Press ESC to see cursor and interact with UI
- **Toggle**: Press ESC again to recapture and continue playing

### Camera Rotation:
- **Left/Right** - Rotate horizontally (360°)
- **Up/Down** - Look up/down (limited to -80° to +80°)
- Camera smoothly follows character while you control the view angle

## Mobile Controls

### Touch Controls:
- **Virtual Joystick** (bottom-left) - Move character
- **Two-Finger Drag** - Rotate camera
- **Jump Button** - Jump (if added)

### Camera Rotation on Mobile:
- Use **two fingers** and drag across screen to rotate camera
- One finger is reserved for the virtual joystick
- Camera rotation sensitivity can be adjusted in settings

## Visual Indicators

### Movement Arrow (Bottom Center):
- **Yellow Arrow** - Shows direction character is currently moving
- Rotates based on camera orientation
- Only visible when character is moving

### Compass (Top-Right Corner):
- Shows cardinal directions (N/S/E/W)
- **Red Arrow** - Points North
- Updates based on camera rotation

## Tips

### For Desktop:
1. **If camera won't rotate**: Make sure mouse is captured (press ESC to toggle)
2. **Sensitivity too high/low**: Adjust `mouse_sensitivity` in camera script (default: 0.003)
3. **Can't see cursor**: Press ESC to release mouse

### For Mobile:
1. **Camera rotation not smooth**: Increase `touch_sensitivity` in camera script
2. **Joystick too sensitive**: Adjust `deadzone` in virtual joystick script
3. **Can't move and rotate**: Use one finger for joystick, two fingers for camera

## Customization

### Adjust Camera Sensitivity:
Open `player/follow_camera_improved.gd` and modify:
```gdscript
@export var mouse_sensitivity := 0.003    # Lower = slower rotation
@export var touch_sensitivity := 0.005    # Adjust for mobile
```

### Adjust Camera Limits:
```gdscript
@export var min_vertical_angle := -80.0   # How far down you can look
@export var max_vertical_angle := 80.0    # How far up you can look
```

### Adjust Camera Distance:
```gdscript
@export var min_distance := 0.5   # Closest zoom
@export var max_distance := 3.0   # Farthest zoom
```

## Troubleshooting

**Camera not rotating:**
- ✅ Check if improved camera script is attached (should be `follow_camera_improved.gd`)
- ✅ Make sure mouse is captured (press ESC if you see cursor)
- ✅ Check console for errors

**Mouse stuck captured:**
- Press **ESC** to release
- If still stuck, restart game

**Camera rotating too fast/slow:**
- Adjust `mouse_sensitivity` or `touch_sensitivity` in camera script
- Try values between 0.001 (very slow) and 0.01 (very fast)

**Indicators not showing:**
- Check if CanvasLayer is visible in scene
- Verify player is in "player" group
- Check console for script errors

---

**Quick Reference:**
- Move: **WASD** / Virtual Joystick
- Rotate Camera: **Mouse** / Two-finger drag
- Jump: **Space** / Touch button
- Toggle Cursor: **ESC**
