# Day/Night Cycle System Guide

## Overview

The day/night cycle system simulates a realistic 24-hour sun movement with dynamic lighting, colors, and a sun compass indicator.

## Features

✅ **Realistic Sun Movement** - Sun rises in east, sets in west, follows natural arc
✅ **24-Hour Cycle** - Configurable speed (default: 2 minutes = 24 hours)
✅ **Dynamic Lighting** - Light intensity and color change based on time
✅ **Sun Compass** - Shows sun position on compass with elevation
✅ **Time Display** - Current game time shown on screen
✅ **Moon at Night** - When sun is below horizon, moon appears
✅ **Keyboard Controls** - Speed up, slow down, pause, jump to times

---

## How It Works

### Sun Path

The sun follows a realistic arc across the sky:
- **6:00 AM (Sunrise)** - Sun at horizon in the east
- **12:00 PM (Noon)** - Sun directly overhead (zenith)
- **6:00 PM (Sunset)** - Sun at horizon in the west
- **12:00 AM (Midnight)** - Sun below horizon (night)

### Time Phases

| Time | Phase | Light Intensity | Color |
|------|-------|----------------|-------|
| 00:00-05:00 | Night | 0.1 | Bluish |
| 05:00-07:00 | Sunrise | 0.1 → 1.3 | Blue → Orange |
| 07:00-17:00 | Day | 1.3 | White |
| 17:00-19:00 | Sunset | 1.3 → 0.1 | White → Red/Orange |
| 19:00-24:00 | Night | 0.1 | Bluish |

---

## Keyboard Controls

### Time Control:
- **Page Up** - Speed up time (2x faster each press, max 100x)
- **Page Down** - Slow down time (2x slower each press, min 0.1x)
- **Home** - Pause/Resume time

### Quick Jump to Times (for testing):
- **1** - Jump to 06:00 (sunrise)
- **2** - Jump to 12:00 (noon)
- **3** - Jump to 18:00 (sunset)
- **4** - Jump to 00:00 (midnight)

---

## Compass Features

### What the Compass Shows:

1. **North Indicator** (Red arrow) - Always points to world north
2. **Cardinal Markers** (Red/white dots) - N, E, S, W positions
3. **Sun Position** (Yellow sun icon) - Shows where sun is in sky
4. **Moon Position** (White moon) - Visible when sun is below horizon
5. **Time Display** - Current game time (HH:MM format)

### Sun Indicator:

- **Distance from center** = Sun's elevation
  - At center = Zenith (directly overhead)
  - At edge = Horizon
- **Position around compass** = Sun's azimuth (direction)
  - Top = North
  - Right = East
  - Bottom = South
  - Left = West
- **Color changes**:
  - Near horizon = Orange (sunrise/sunset)
  - High in sky = Bright yellow/white (midday)
- **Sun rays** animate around the sun icon

### Moon Indicator:

- Appears opposite to sun when sun is below horizon
- Crescent shape
- Bluish-white color
- Positioned at ~50% radius from center

---

## Configuration

### In Godot Editor:

Select the **DirectionalLight3D** node to see these export variables:

#### Time Settings:
```gdscript
@export var cycle_duration_seconds := 120.0  # 2 minutes = 24 hours
@export var start_time := 6.0                # Start at 6 AM
@export var time_scale := 1.0                # Speed multiplier
@export var paused := false                  # Start paused
```

**Examples:**
- Fast cycle: `cycle_duration_seconds = 60.0` (1 minute = 24 hours)
- Slow cycle: `cycle_duration_seconds = 600.0` (10 minutes = 24 hours)
- Real-time: `cycle_duration_seconds = 86400.0` (24 real hours)

#### Sun Path Settings:
```gdscript
@export var sun_latitude := 45.0       # Affects sun arc height
@export var sun_east_direction := 90.0  # Which direction is east (degrees)
```

**Latitude effects:**
- `0°` (Equator) - Sun goes almost directly overhead
- `45°` (Mid-latitude) - Realistic arc for most locations
- `66°+` (Arctic) - Low sun angle, never overhead

#### Light Settings:
```gdscript
@export var day_intensity := 1.3
@export var night_intensity := 0.1
@export var sunrise_sunset_intensity := 0.6
```

#### Light Colors:
```gdscript
@export var day_color := Color(1.0, 1.0, 1.0, 1.0)      # White
@export var sunrise_color := Color(1.0, 0.6, 0.3, 1.0)  # Orange
@export var sunset_color := Color(1.0, 0.4, 0.2, 1.0)   # Red-orange
@export var night_color := Color(0.4, 0.5, 0.8, 1.0)    # Bluish
```

---

## Direction Indicator Settings

Select the **DirectionIndicator** Control node to configure compass:

```gdscript
@export var show_compass := true   # Show/hide compass
@export var show_sun := true       # Show/hide sun on compass
@export var show_time := true      # Show/hide time display
@export var compass_offset := Vector2(80, 80)  # Position from corner
```

---

## Scripting API

### Access from Code:

```gdscript
# Get reference to day/night cycle
var day_cycle = get_tree().root.find_child("DirectionalLight3D", true, false)

# Check time
var current_time = day_cycle.current_time  # 0-24 hours
var time_string = day_cycle.get_time_string()  # "06:30"
var time_of_day = day_cycle.get_time_of_day()  # "sunrise", "day", "sunset", "night"

# Sun position
var sun_direction = day_cycle.get_sun_direction()  # Vector3
var sun_azimuth = day_cycle.get_sun_azimuth()  # 0-360 degrees
var sun_elevation = day_cycle.get_sun_elevation()  # -90 to 90 degrees

# Control time
day_cycle.set_time(12.0)  # Set to noon
day_cycle.skip_to_time(18.0)  # Jump to sunset
day_cycle.time_scale = 2.0  # 2x speed
day_cycle.paused = true  # Pause time
```

### Create Day/Night Events:

```gdscript
func _process(delta):
	var day_cycle = get_tree().root.find_child("DirectionalLight3D", true, false)

	match day_cycle.get_time_of_day():
		"sunrise":
			# Trigger sunrise events (birds chirping, etc.)
			pass
		"day":
			# Daytime behavior
			pass
		"sunset":
			# Trigger sunset events
			pass
		"night":
			# Nighttime behavior (monsters spawn, lights turn on, etc.)
			pass
```

### Time-Based Triggers:

```gdscript
func _process(delta):
	var day_cycle = get_tree().root.find_child("DirectionalLight3D", true, false)
	var time = day_cycle.current_time

	if time >= 6.0 and time < 6.1:  # Around 6 AM
		# Trigger morning event (only once)
		print("Good morning!")

	if time >= 20.0 and time < 20.1:  # Around 8 PM
		# Turn on street lights
		activate_street_lights()
```

---

## Visual Examples

### Compass States:

**Morning (6 AM):**
```
    🔴 (North)

⚪     ☀     ⚪
(W)          (E)

    ⚪
   (South)

Time: 06:00
```

**Noon (12 PM):**
```
    🔴 (North)

⚪     ☀     ⚪
(W)   (↑)    (E)

    ⚪
   (South)

Time: 12:00
```
*Sun at center (zenith)*

**Evening (6 PM):**
```
    🔴 (North)

⚪     ☀     ⚪
(W)          (E)

    ⚪
   (South)

Time: 18:00
```

**Night (12 AM):**
```
    🔴 (North)

⚪           ⚪
(W)   🌙    (E)

    ⚪
   (South)

Time: 00:00
```
*Moon visible, opposite to sun*

---

## Troubleshooting

### Sun not moving:
- Check if time is paused (press Home to unpause)
- Verify `time_scale > 0`
- Check console for "Day/Night Cycle: Started" message

### Compass not showing sun:
- Make sure `show_sun = true` in DirectionIndicator
- Verify DirectionalLight3D has `day_night_cycle.gd` script attached
- Check console for "Sun/DirectionalLight3D found" message

### Time display not showing:
- Enable `show_time = true` in DirectionIndicator
- Verify script is attached to DirectionalLight3D

### Wrong sun colors:
- Adjust color exports in DirectionalLight3D inspector
- Check if custom Environment is overriding colors

### Sun position doesn't match compass:
- Verify `sun_east_direction = 90.0` (default)
- Check that world's forward direction is negative Z

---

## Advanced: Custom Sky Colors

To make sky change color with time, modify the WorldEnvironment:

```gdscript
# Add to day_night_cycle.gd

@onready var world_env = get_tree().root.find_child("WorldEnvironment", true, false)

func update_light_properties():
	# ... existing code ...

	# Update sky color
	if world_env and world_env.environment:
		var env = world_env.environment
		match get_time_of_day():
			"sunrise":
				env.sky.sky_material.sky_top_color = Color(1.0, 0.6, 0.4)
			"day":
				env.sky.sky_material.sky_top_color = Color(0.5, 0.7, 1.0)
			"sunset":
				env.sky.sky_material.sky_top_color = Color(1.0, 0.5, 0.3)
			"night":
				env.sky.sky_material.sky_top_color = Color(0.1, 0.1, 0.3)
```

---

## Tips

1. **For realistic gameplay**: Set `cycle_duration_seconds = 300` (5 min = 24h)
2. **For testing**: Use keyboard shortcuts (1-4) to jump between times
3. **For cutscenes**: Pause time and set specific time with `set_time()`
4. **For dramatic effect**: Lower `time_scale` during important moments
5. **For survival games**: Use `get_time_of_day()` to trigger enemy spawns at night

---

## Summary

The day/night cycle creates a living, breathing world:
- ☀ Sun moves realistically across sky
- 🌙 Moon appears at night
- 🧭 Compass tracks sun position in real-time
- ⏰ Time displayed and controllable
- 🎨 Dynamic lighting and colors

Enjoy your dynamic day/night world! 🌅🌞🌙
