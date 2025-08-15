# Shooting System Documentation

A complete projectile-based shooting system with crosshair aiming and accuracy-based spread.

## ✅ **Features Implemented**

### **🎯 Crosshair System**
- **Dynamic Visibility**: Only shows when ranged weapon is equipped
- **Ammo Indicator**: Changes color (white = can shoot, red = no ammo)
- **Center Screen Aiming**: Crosshair appears at screen center
- **Auto-Detection**: Automatically detects ranged weapons in either hand

### **🔫 Projectile System**
- **Physics-Based Bullets**: RigidBody3D projectiles with realistic physics
- **Damage System**: Bullets carry weapon damage values
- **Lifetime Management**: Bullets auto-destroy after set time
- **Hit Detection**: Collision-based hit detection with damage application

### **🎲 Accuracy System**
- **Weapon-Based Spread**: Each weapon has accuracy rating (0.0-1.0)
- **Dynamic Spread**: Lower accuracy = wider bullet spread
- **Realistic Ballistics**: Bullets follow physics with slight gravity effect

### **⚙️ Integration**
- **Hand System**: Fully integrated with dual-hand equipment system
- **Signal-Based**: Clean signal system for projectile spawning
- **Performance**: Efficient cleanup and memory management

## 🎮 **How to Use**

### **Controls**
- **Equip Ranged Weapon**: Use number keys (1, 2, etc.) to equip weapons
- **Aim**: Move mouse to aim (crosshair follows screen center)
- **Shoot**: Left/Right mouse buttons (depending on which hand holds weapon)
- **Reload**: Right mouse button (secondary action for ranged weapons)

### **Setting Up Ranged Weapons**

1. **Create Weapon Resource** (`.tres` file):
```gdscript
[resource]
script = ExtResource("ranged_weapon_script")
item_name = "Heavy Pistol"
category = "ranged"
damage = 25.0
accuracy = 0.75  # 75% accuracy
rpm = 180.0      # Rate of fire
magazine_size = 8
reload_time = 2.5
# ... other properties
```

2. **Add to Player Inventory**:
   - Select Player3d node in scene
   - In Inspector, expand "Available Items"
   - Add your `.tres` file to the array

3. **Test In-Game**:
   - Press number key to equip weapon
   - Crosshair should appear
   - Left/Right click to shoot
   - Watch console for debug output

## 🔧 **Technical Details**

### **Crosshair (crosshair.gd)**
- Draws custom crosshair using `_draw()` function
- Monitors hand equipment changes via signals
- Updates color based on ammo availability
- Provides world position calculation for aiming

### **Bullet (bullet.gd)**
- RigidBody3D with collision detection
- Carries damage, speed, and shooter information
- Auto-cleanup after lifetime expires
- Hit effects and damage application

### **Hand Integration**
- `projectile_fired` signal connects hand to player
- Accuracy-based spread calculation
- Muzzle position detection (from weapon model)
- Cooldown management based on weapon RPM

### **Player Controller**
- Handles projectile instantiation
- Manages projectile spawning in world space
- Connects hand signals to projectile system

## 📊 **Weapon Stats Explained**

### **Accuracy** (0.0 - 1.0)
- **1.0**: Perfect accuracy, no spread
- **0.75**: Good accuracy, slight spread
- **0.5**: Moderate accuracy, noticeable spread
- **0.25**: Poor accuracy, wide spread

### **RPM** (Rounds Per Minute)
- **600 RPM**: Fast automatic fire
- **180 RPM**: Semi-automatic pistol
- **60 RPM**: Slow, powerful weapon
- Affects cooldown between shots

### **Damage**
- Applied to targets with `take_damage()` method
- Carried by bullet projectile
- Can vary per weapon type

## 🎨 **Customization Options**

### **Crosshair Appearance**
```gdscript
# In crosshair.gd
@export var crosshair_size: float = 20.0
@export var crosshair_thickness: float = 2.0
@export var crosshair_gap: float = 5.0
@export var crosshair_color: Color = Color.WHITE
```

### **Bullet Properties**
```gdscript
# In bullet.gd
@export var speed: float = 50.0
@export var lifetime: float = 5.0
@export var gravity_scale: float = 0.1
```

### **Spread Settings**
```gdscript
# In hand.gd get_aim_direction_with_spread()
var max_spread = deg_to_rad(10.0)  # Maximum spread angle
```

## 🐛 **Troubleshooting**

### **Crosshair Not Appearing**
- Check if ranged weapon is properly equipped
- Verify weapon has `category = "ranged"`
- Check console for connection errors

### **Bullets Not Spawning**
- Verify bullet scene path in Hand class
- Check projectile_fired signal connections
- Look for instantiation errors in console

### **No Hit Detection**
- Ensure bullet collision layers are set correctly
- Check target objects have collision shapes
- Verify `take_damage()` method exists on targets

### **Accuracy Issues**
- Check weapon accuracy value (0.0-1.0 range)
- Verify spread calculation in `get_aim_direction_with_spread()`
- Test with accuracy = 1.0 for perfect shots

## 🚀 **Future Enhancements**

### **Possible Additions**
- **Muzzle Flash**: Visual effects at shot origin
- **Shell Casings**: Ejected bullet casings
- **Hit Particles**: Impact effects on surfaces
- **Ricochet**: Bullets bouncing off surfaces
- **Penetration**: Bullets going through thin objects
- **Tracer Rounds**: Visible bullet trails
- **Sound Effects**: Gunshot and reload sounds

The system is designed to be easily extensible for these features!
