# Third-Person Character Controller with State Machine

This is a comprehensive third-person character controller for Godot 4 with a node-based state machine system.

## Features

### Player Configuration System
- **Stat-based system**: might, fortitude, motorics
- **Calculated properties**: weight, speed, jump_height, dash_length, sprint_multiplier
- **Configurable formulas** for realistic character progression

### State Machine
- **Node-based architecture** for easy debugging and modification
- **7 different states**: Idle, Moving, Jumping, Falling, Dashing, Crouching, Wallrunning
- **Smooth transitions** between states based on input and physics

### Camera System
- **Walking sway** that responds to movement speed
- **Camera shake** for impacts and actions
- **Dynamic FOV** that increases with speed
- **Third-person mouse look** with pitch/yaw controls

### Input Actions
- `forward` (W) - Move forward
- `backward` (S) - Move backward  
- `left` (A) - Move left
- `right` (D) - Move right
- `jump` (Space) - Jump with variable height and coyote time
- `dash` (V) - Dash in movement direction
- `sprint` (Left Shift) - Sprint while moving forward
- `crouch` (C) - Crouch/crawl
- `activate` (E) - Interact with objects
- `attack` (Left Mouse) - Attack (placeholder)
- `attack_alternate` (Right Mouse) - Alternate attack (placeholder)

## Architecture

### Core Files
- `player_3d.gd` - Main player controller
- `player_config.gd` - Configuration and stat system
- `camera_controller.gd` - Camera effects and controls

### State System
- `states/state.gd` - Base state class
- `states/state_machine.gd` - State machine manager
- `states/idle_state.gd` - Standing still
- `states/moving_state.gd` - Walking, running, sprinting
- `states/jumping_state.gd` - Ascending from jump
- `states/falling_state.gd` - Falling/airborne
- `states/dashing_state.gd` - Quick dash movement
- `states/crouching_state.gd` - Crouching and crawling
- `states/wallrunning_state.gd` - Wall running (basic implementation)

## Usage

1. **Scene Setup**: The player scene (`player_3d.tscn`) is already configured with all necessary nodes
2. **Configuration**: Modify the `player_config` export variable in the inspector to adjust stats
3. **Controls**: Use WASD for movement, Space for jump, Shift for sprint, etc.
4. **State Debugging**: Check console output to see state transitions

## Customization

### Adding New States
1. Create a new script extending `State`
2. Implement `enter()`, `exit()`, `physics_update()`, and `get_state_name()`
3. Add the state as a child of the StateMachine node
4. Add transition logic in relevant existing states

### Modifying Stats
Edit the formulas in `player_config.gd`:
```gdscript
var weight: float:
    get:
        return starting_weight + ((fortitude * 10) + (might * 5))

var speed: float:
    get:
        return (motorics * 5) / (weight / 10 - might)
```

### Camera Effects
Adjust camera properties in `camera_controller.gd`:
- `sway_intensity` - Walking sway strength
- `max_speed_fov_bonus` - FOV increase at high speeds  
- `shake_decay` - How quickly camera shake fades

## Notes

- **Wallrunning** requires additional wall detection implementation
- **Crouching** needs collision shape height adjustment for full functionality
- **Attack system** is placeholder - implement based on your game's needs
- All movement values are tuned for a standard character size (2 units tall)

## Controls Summary
- **WASD** - Movement
- **Mouse** - Look around
- **Space** - Jump (hold for higher jump)
- **Left Shift** - Sprint (while moving forward)
- **V** - Dash
- **C** - Crouch
- **E** - Interact
- **Left/Right Mouse** - Attack (placeholder)
