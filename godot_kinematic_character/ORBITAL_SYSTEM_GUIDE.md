# Orbital Mechanics System Guide

## 🌍 Overview

The orbital system transforms your scene into a realistic space environment where **you orbit around the sun** alongside a **moon planet**. Gravity, lighting, and physics all respond to your orbital position!

## 🎯 Key Concepts

### You Are Orbiting
- Your scene (the platform) orbits around a central sun
- Think of yourself as on a small planet or space station
- The sun doesn't rotate around you - **you rotate around it!**

### The Moon is a Planet
- The moon is actually another planet in orbit
- It has its own independent orbit around the sun
- Sometimes it passes between you and the sun (eclipse!)
- It's much larger than your scene (like how Mars appears from Earth)

### Dynamic Gravity
- **Closer to sun** = Stronger gravity pull
- **Farther from sun** = Weaker gravity pull
- **During eclipse** = Moon's gravity helps reduce sun's pull
- Gravity pulls mostly downward, with slight pull toward sun

---

## 🌟 Features

### ✅ Orbital Motion
- Scene orbits sun in circular path
- Configurable orbit radius and speed
- Real-time position tracking

### ✅ Moon System
- Independent planetary orbit
- Larger than your scene (planet-sized)
- Visible on compass at all times
- Glows orange/red during eclipse

### ✅ Eclipse Mechanics
- Occurs when moon passes between you and sun
- Dims the sunlight
- Moon glows with eclipse aura
- Reduces gravity (moon's pull counteracts sun)
- Shows eclipse percentage

### ✅ Dynamic Gravity
- Based on inverse-square law (simplified)
- Affects character movement and jumps
- Direction pulls toward sun (slightly)
- Visual indicator shows current gravity

### ✅ Compass Integration
- Shows sun position (yellow, with rays)
- Shows moon position (white/blue crescent)
- Shows current gravity (color-coded)
- Eclipse status when active

---

## 🎮 Controls

### Orbital Controls:
- **F1** - Speed up orbit (2x faster)
- **F2** - Slow down orbit (2x slower)
- **F3** - Speed up moon orbit
- **F4** - Slow down moon orbit
- **F5** - Print orbital status to console

### Day/Night Controls (still work):
- **Page Up/Down** - Speed up/slow down time
- **Home** - Pause/resume time
- **1/2/3/4** - Jump to different times

### Character Movement:
- **WASD** - Move (affected by gravity!)
- **Space** - Jump (height varies with gravity)
- **Mouse** - Rotate camera

---

## 📊 Compass Display

### What You See:

```
    🔴 (North arrow)

⚪  ☀️  🌙  ⚪
(W) sun moon (E)

    ⚪ (S)

    G: 9.8 m/s²
```

**Elements:**
1. **Red North Arrow** - World north direction
2. **Yellow Sun** (☀️) - Where the sun is in the sky
   - With animated rays
   - Moves as you orbit
3. **White/Blue Moon** (🌙) - Moon planet position
   - Always visible (it's orbiting too)
   - Glows orange during eclipse
   - Shows crescent phase
4. **Gravity Display** - Current gravity strength
   - White = Normal (7-12 m/s²)
   - Red = High (>12 m/s²)
   - Blue = Low (<7 m/s²)

### During Eclipse:
```
    🔴

⚪  ☀️  🌙💥  ⚪
        ↑
     ECLIPSE 85%

    G: 6.8 m/s² (reduced!)
```

---

## ⚙️ Configuration

### In Godot Editor:

Select the **OrbitalSystem** node to see export variables:

#### Orbital Settings:
```gdscript
@export var orbit_radius := 10.0      # Distance from sun (affects gravity)
@export var orbit_speed := 0.1        # How fast you orbit (radians/sec)
@export var orbit_angle := 0.0        # Starting position in orbit
```

**Examples:**
- Close orbit (high gravity): `orbit_radius = 5.0`
- Far orbit (low gravity): `orbit_radius = 20.0`
- Fast orbit: `orbit_speed = 0.5`
- Slow orbit: `orbit_speed = 0.05`

#### Moon Settings:
```gdscript
@export var moon_orbit_radius := 15.0  # Moon's distance from sun
@export var moon_orbit_speed := 0.15   # Moon's orbital speed
@export var moon_angle := PI           # Moon's starting position
@export var moon_size := 2.0           # Moon radius (for eclipse calc)
```

**Moon Orbit Tips:**
- `moon_orbit_radius > orbit_radius` - Moon outside your orbit
- `moon_orbit_radius < orbit_radius` - You orbit outside moon
- `moon_orbit_speed > orbit_speed` - Moon orbits faster (more eclipses)

#### Gravity Settings:
```gdscript
@export var base_gravity := 9.8                    # Earth-like gravity at orbit_radius
@export var gravity_strength_multiplier := 1.0    # How much distance affects gravity
@export var eclipse_gravity_reduction := 0.3      # Gravity reduction during eclipse
```

**Gravity Formula:**
```
gravity = base_gravity * (orbit_radius / current_distance)² * multiplier
```

During eclipse:
```
gravity = gravity * (1 - eclipse_amount * eclipse_gravity_reduction)
```

#### Eclipse Settings:
```gdscript
@export var eclipse_light_reduction := 0.7  # How much to dim light (0-1)
```

---

## 🎯 Gameplay Effects

### High Gravity (Close to Sun):
- **Stronger pull downward**
- Falls faster
- Jumps lower
- Harder to change direction mid-air
- Shown in red on compass

### Low Gravity (Far from Sun):
- **Weaker pull**
- Falls slower (floaty)
- Jumps higher
- Easier to control in air
- Shown in blue on compass

### During Eclipse:
- **Light dims** (dramatic shadow)
- **Gravity reduces** (moon helps you)
- **Moon glows** orange/red
- **Shows percentage** of eclipse
- Rare event (depending on orbital speeds)

---

## 📐 How It Works

### Orbital Mechanics:

Your position in orbit:
```gdscript
position = Vector2(cos(orbit_angle) * orbit_radius,
                   sin(orbit_angle) * orbit_radius)
```

Updates each frame:
```gdscript
orbit_angle += orbit_speed * delta
```

### Eclipse Detection:

1. Calculate your position relative to sun
2. Calculate moon position relative to sun
3. Check if moon is between you and sun:
   - Angular alignment check
   - Distance check (moon must be closer to sun than you)
4. Calculate coverage percentage

### Gravity Calculation:

Inverse-square law (simplified):
```gdscript
gravity = base_gravity * pow(orbit_radius / distance, 2.0)
```

Direction:
```gdscript
# Mostly down, slightly toward sun
gravity_dir = Vector3.DOWN.lerp(toward_sun, 0.2)
```

---

## 🎨 Visual Guide

### Normal Day:
```
      SUN ☀️
       |
       | (your orbit)
       |
    YOU 🟦 ← (platform)

    ↓ Strong sunlight
    ↓ Normal gravity
```

### Eclipse Event:
```
      SUN ☀️
       |
       | MOON 🌙
       |/  ↖️ (blocks sun)
      YOU 🟦

    ↓ Dim light
    ↓ Reduced gravity!
```

### Orbital View (Top-Down):
```
         N
         ↑
    ⬤ ← Sun (center)

 W ←  ○  → E
   ↗️ ↘️
  🟦  🌙  (orbiting)
  You  Moon

         ↓
         S
```

---

## 🎓 Scripting API

### Access Orbital System:

```gdscript
var orbital = get_tree().root.find_child("OrbitalSystem", true, false)
```

### Get Current State:

```gdscript
# Gravity
var gravity = orbital.get_gravity()  # Current gravity value
var grav_dir = orbital.get_gravity_direction()  # Vector3 direction

# Position
var pos = orbital.get_orbital_position()  # Vector2 in orbit
var distance = orbital.get_distance_to_sun()  # float

# Directions
var sun_dir = orbital.get_sun_direction_orbital()  # Vector2 to sun
var moon_dir = orbital.get_moon_direction_orbital()  # Vector2 to moon

# Eclipse
var eclipse_info = orbital.get_eclipse_info()  # Dictionary
var is_eclipsed = eclipse_info["is_eclipsed"]  # bool
var eclipse_amount = eclipse_info["eclipse_amount"]  # 0-1
```

### Examples:

**Spawn enemies during eclipse:**
```gdscript
func _process(delta):
	var orbital = get_tree().root.find_child("OrbitalSystem", true, false)
	if orbital:
		var eclipse = orbital.get_eclipse_info()
		if eclipse["is_eclipsed"] and eclipse["eclipse_amount"] > 0.5:
			spawn_shadow_enemies()
```

**Adjust movement speed by gravity:**
```gdscript
func _physics_process(delta):
	var orbital = get_tree().root.find_child("OrbitalSystem", true, false)
	if orbital:
		var gravity = orbital.get_gravity()
		var speed_multiplier = 9.8 / gravity  # Inverse of gravity
		MAX_SPEED = BASE_SPEED * speed_multiplier
```

**Create orbital-based puzzles:**
```gdscript
# Door opens only at certain orbital positions
func _process(delta):
	var orbital = get_tree().root.find_child("OrbitalSystem", true, false)
	if orbital:
		var angle = orbital.orbit_angle
		if angle > PI * 0.4 and angle < PI * 0.6:  # Quarter orbit
			open_door()
```

---

## 🎮 Gameplay Ideas

### Survival Mode:
- Higher gravity = more damage from falls
- Eclipses spawn enemies
- Collect resources only available at certain orbital positions

### Racing Mode:
- Complete laps faster in low gravity zones
- Time eclipses for speed boosts

### Puzzle Mode:
- Objects only accessible at specific orbital positions
- Use gravity changes to solve platforming puzzles
- Sync with moon position for special abilities

### Exploration Mode:
- Different biomes at different orbital positions
- Eclipse reveals hidden areas
- Moon proximity triggers events

---

## 🐛 Troubleshooting

**Gravity not changing:**
- Check if OrbitalSystem node exists in scene
- Verify orbit_speed > 0
- Check console for "Orbital system found" message

**No eclipse happening:**
- Moon might orbit too fast/slow (adjust speeds)
- Check moon_orbit_radius (should be close to your orbit_radius)
- Try `moon_orbit_speed = orbit_speed * 1.2` for regular eclipses

**Character floating away:**
- Gravity might be too low
- Increase `base_gravity` or decrease `orbit_radius`
- Check if gravity multiplier is reasonable

**Eclipse too frequent/rare:**
- Adjust `moon_orbit_speed` relative to `orbit_speed`
- Change `moon_orbit_radius` to cross your orbit path
- Modify `moon_size` for eclipse detection range

---

## 📚 Technical Notes

### Performance:
- Orbital calculations are lightweight (2D vector math)
- No physics simulation - just visual/gameplay effects
- Runs at full framerate

### Accuracy:
- Simplified orbital mechanics (circular, not elliptical)
- Gravity uses simplified inverse-square law
- Eclipse detection uses angular approximation

### Compatibility:
- Works with existing day/night cycle
- Compatible with all character controllers
- No conflicts with other systems

---

## 🌟 Summary

You now have a fully functional **orbital mechanics system** where:
- ✅ Your scene orbits the sun realistically
- ✅ Moon is a separate orbiting planet
- ✅ Gravity changes based on position
- ✅ Eclipses create dramatic events
- ✅ Compass tracks everything in real-time
- ✅ Fully customizable and scriptable

**The universe is yours to explore!** 🚀🌍🌙☀️

---

**Pro Tip:** Start with default settings, then use **F5** to check orbital status and adjust from there. Use eclipses as special gameplay moments!
