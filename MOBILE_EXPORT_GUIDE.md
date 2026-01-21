# Mobile Export Guide for Godot 4

## Prerequisites

### For Android:
1. **Android SDK** (via Android Studio or command line tools)
   - Install Android Studio: https://developer.android.com/studio
   - Or install sdkmanager: https://developer.android.com/tools/sdkmanager

2. **Godot Export Templates**
   - In Godot Editor: **Editor → Manage Export Templates**
   - Download templates for your Godot version

3. **Java JDK** (OpenJDK 17 recommended)
   - Download from: https://adoptium.net/

### For iOS/iPad:
1. **macOS computer** (required for iOS builds)
2. **Xcode** (latest version from App Store)
3. **Apple Developer Account** ($99/year)
4. **iOS device** for testing (simulator has limitations)

---

## Android Export Setup

### Step 1: Configure Android SDK in Godot

1. Open Godot Editor
2. Go to **Editor → Editor Settings → Export → Android**
3. Set these paths:
   ```
   Android SDK Path: /path/to/Android/Sdk
   Debug Keystore: (auto-generated or use custom)
   Debug Keystore User: androiddebugkey
   Debug Keystore Password: android
   ```

### Step 2: Create Android Export Preset

1. **Project → Export → Add → Android**
2. Configure these settings:

#### Basic Settings:
```
Name: Android
Runnable: ✓ (checked)
Export Path: builds/android/kinematic_character.apk
```

#### Options → Application:
```
Permissions:
  - ACCESS_NETWORK_STATE (optional, for online features)
  - INTERNET (optional, for online features)

Screen Orientation:
  - sensor_landscape (auto-rotates between landscape modes)
  OR
  - landscape (locked to landscape)
  OR
  - portrait (for vertical gameplay)
```

#### Options → Graphics:
```
XR Mode: Regular
```

#### Options → Package:
```
Unique Name: com.yourname.kinematiccharacter
  (must be unique, use your domain reversed)
  Example: com.johndoe.kinematiccharacter

Name: Kinematic Character 3D
Version Code: 1 (increment for each release)
Version Name: 1.0.0

Min SDK: 21 (Android 5.0)
Target SDK: 33 (Android 13)
```

### Step 3: Build Android APK

#### Debug Build (for testing):
1. Click **Export Project**
2. Choose location: `builds/android/kinematic_character_debug.apk`
3. Click **Save**
4. APK will be built

#### Release Build (for Google Play):
1. Create release keystore:
   ```bash
   keytool -genkey -v -keystore release.keystore -alias release \
           -keyalg RSA -keysize 2048 -validity 10000
   ```
2. In Export Preset:
   - Enable **Custom Build**
   - Set **Keystore** path to your release.keystore
   - Enter **Keystore User** (alias)
   - Enter **Keystore Password**
3. Export as before

#### Install on Android Device:
```bash
adb install builds/android/kinematic_character_debug.apk
```

Or transfer APK to device and install manually.

---

## iOS Export Setup

### Step 1: Configure Xcode Settings in Godot

1. Godot will use Xcode for iOS builds
2. Ensure Xcode Command Line Tools are installed:
   ```bash
   xcode-select --install
   ```

### Step 2: Create iOS Export Preset

1. **Project → Export → Add → iOS**
2. Configure these settings:

#### Application:
```
App Store Team ID: Your 10-character Team ID
  (Find in Apple Developer Portal)

Identifier / Bundle ID: com.yourname.kinematiccharacter
  (Must match provisioning profile)

Version: 1.0.0
Short Version: 1.0
```

#### Icons:
Set all required icon sizes (can use same image, Godot will resize):
- iPhone Notification (40x40, 60x60)
- iPhone Settings (58x58, 87x87)
- iPhone Spotlight (80x80, 120x120)
- iPhone App (120x120, 180x180)
- iPad Notifications (20x20, 40x40)
- iPad Settings (29x29, 58x58)
- iPad Spotlight (40x40, 80x80)
- iPad App (76x76, 152x152)
- App Store (1024x1024)

#### Launch Screen:
```
Use Launch Screen Storyboard: ✓
Launch Screen Image: (optional splash image)
Background Color: #000000 (or your color)
```

#### Required Device Capabilities:
```
- armv7 (for older devices)
- arm64 (for newer devices)
```

#### Orientation:
```
Portrait: ☐
Landscape Left: ✓
Landscape Right: ✓
```

### Step 3: Provisioning Profile Setup

1. Go to: https://developer.apple.com/account/
2. **Certificates, Identifiers & Profiles**

#### Create App ID:
- Click **Identifiers** → **+**
- Select **App IDs** → **App**
- Description: Kinematic Character 3D
- Bundle ID: com.yourname.kinematiccharacter
- Capabilities: (select what you need)
- Save

#### Create Provisioning Profile:
- Click **Profiles** → **+**
- Select **iOS App Development** (for testing)
- OR **App Store** (for release)
- Select your App ID
- Select your certificate
- Select test devices (for development)
- Download the `.mobileprovision` file

#### In Godot Export Preset:
```
Provisioning Profile UUID:
  (Copy UUID from provisioning profile name or open the file to find it)
```

### Step 4: Build iOS Project

1. Click **Export Project**
2. Choose location: `builds/ios/`
3. Export as **Xcode Project**
4. Godot will generate an Xcode project

### Step 5: Build in Xcode

1. Open `builds/ios/kinematic_character.xcodeproj` in Xcode
2. Select your development team
3. Select target device or simulator
4. Click **Play** button to build and run
5. For App Store:
   - **Product → Archive**
   - Upload to App Store Connect

---

## Touch Controls for Mobile

### Add Virtual Joystick

Create a touch joystick scene:

```gdscript
# virtual_joystick.gd
extends Control

signal direction_changed(direction: Vector2)

@export var max_distance := 50.0
var touch_index := -1
var center_pos := Vector2.ZERO
var current_pos := Vector2.ZERO

func _ready():
	center_pos = size / 2

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed and touch_index == -1:
			touch_index = event.index
			current_pos = event.position
		elif not event.pressed and touch_index == event.index:
			touch_index = -1
			current_pos = center_pos
			direction_changed.emit(Vector2.ZERO)

	elif event is InputEventScreenDrag:
		if event.index == touch_index:
			current_pos = event.position
			var direction = (current_pos - center_pos).limit_length(max_distance)
			direction_changed.emit(direction / max_distance)

func _draw():
	# Draw joystick base
	draw_circle(center_pos, max_distance, Color(1, 1, 1, 0.3))
	# Draw joystick stick
	var stick_pos = center_pos + (current_pos - center_pos).limit_length(max_distance)
	draw_circle(stick_pos, 20, Color(1, 1, 1, 0.8))
```

### Modify Character Controller for Touch

In `cubio.gd`, add:
```gdscript
# Add at top
var virtual_joystick_direction := Vector2.ZERO

# Connect to virtual joystick
func _ready():
	var joystick = get_node_or_null("../UI/VirtualJoystick")
	if joystick:
		joystick.direction_changed.connect(_on_joystick_direction_changed)

func _on_joystick_direction_changed(direction: Vector2):
	virtual_joystick_direction = direction

# In _physics_process, replace input reading:
func _physics_process(delta: float) -> void:
	var dir := Vector3()

	# Use virtual joystick if available (mobile)
	if virtual_joystick_direction.length() > 0.1:
		dir.x = virtual_joystick_direction.x
		dir.z = virtual_joystick_direction.y
	else:
		# Fallback to keyboard (desktop)
		dir.x = Input.get_axis(&"move_left", &"move_right")
		dir.z = Input.get_axis(&"move_forward", &"move_back")

	# Rest of movement code...
```

---

## Performance Optimization for Mobile

### 1. Rendering Settings

In `project.godot`, modify:
```ini
[rendering]
renderer/rendering_method="mobile"
renderer/rendering_method.mobile="forward_plus"
textures/vram_compression/import_etc2_astc=true
limits/time/cpu_frame_budget=16
anti_aliasing/quality/msaa_3d=2
anti_aliasing/quality/screen_space_aa=1
```

### 2. Reduce Draw Calls
- Combine meshes where possible
- Use texture atlases
- Reduce number of materials

### 3. Shadow Quality
```gdscript
# In level or camera script
func _ready():
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		# Reduce shadow quality on mobile
		var environment = get_viewport().world_3d.environment
		if environment:
			environment.shadow_quality = RenderingServer.SHADOW_QUALITY_SOFT_LOW
```

### 4. Physics Optimization
- Use simple collision shapes (boxes, spheres)
- Reduce physics tick rate if needed
- Limit number of active physics bodies

### 5. Audio
- Use compressed audio formats (OGG Vorbis)
- Limit simultaneous audio sources

---

## Testing on Physical Devices

### Android:
1. Enable **Developer Options** on device:
   - Go to **Settings → About Phone**
   - Tap **Build Number** 7 times
2. Enable **USB Debugging**
3. Connect device via USB
4. Run: `adb devices` to verify connection
5. In Godot, click **Remote Debug** when exporting

### iOS:
1. Connect device via USB
2. Trust computer on device
3. In Xcode, select your device
4. Build and run
5. Trust developer certificate on device if prompted

---

## Common Issues & Solutions

### Android:

**Issue**: "SDK not found"
- **Solution**: Set Android SDK path in Editor Settings

**Issue**: "Keystore error"
- **Solution**: Use debug keystore or create new release keystore

**Issue**: "App crashes on startup"
- **Solution**: Check logcat: `adb logcat -s godot`

### iOS:

**Issue**: "Code signing failed"
- **Solution**: Select correct team and provisioning profile in Xcode

**Issue**: "App not trusted"
- **Solution**: Settings → General → Device Management → Trust developer

**Issue**: "Provisioning profile doesn't match"
- **Solution**: Ensure Bundle ID matches in Xcode and Developer Portal

---

## Publishing

### Google Play Store:
1. Create developer account ($25 one-time fee)
2. Build signed release APK/AAB
3. Upload to Play Console
4. Fill in store listing details
5. Submit for review

### Apple App Store:
1. Apple Developer account ($99/year)
2. Archive build in Xcode
3. Upload to App Store Connect
4. Fill in app information
5. Submit for review

---

## Useful Resources

- **Godot Docs - Exporting**: https://docs.godotengine.org/en/stable/tutorials/export/
- **Android Developer Docs**: https://developer.android.com/
- **Apple Developer Docs**: https://developer.apple.com/documentation/
- **Godot Mobile Forum**: https://forum.godotengine.org/c/mobile/

---

Ready to export! Test thoroughly on physical devices before publishing.
