# Player Controller - Technical Documentation

## Overview

This document provides technical details about the implementation of the player controller system. The player controller is a modular, state-based system that handles first-person movement, camera control, and interaction mechanics.

## Architecture

The player controller uses a state machine pattern to manage different movement states. This architecture provides clean separation of concerns and makes it easy to add or modify movement behaviors.

### Component Hierarchy

```
Player (CharacterBody3D)
├── CollisionShape3D
├── CameraPivot (CameraController)
│   ├── Camera3D
│   │   └── InteractRayCast (RayCast3D)
│   └── Hands
│       ├── RightHand (Hand)
│       └── LeftHand (Hand)
└── StateMachine
    ├── IdleState
    ├── MovingState
    ├── JumpingState
    ├── FallingState
    ├── DashingState
    ├── SlidingState
    └── WallrunningState
```

## Core Components

### Player (player.gd)

**Location:** `src/fps/player/player.gd`

The main player script extends CharacterBody3D and acts as the central coordinator for all player functionality.

**Responsibilities:**
- Input handling and processing
- Coordination between Camera, Hands, and StateMachine
- Wallrun detection using raycasts
- Interaction system via raycast
- Providing helper functions for movement calculations
- Managing player stats (health, mana, stamina)
- Pause/resume game functionality
- HUD updates

**Key Methods:**
- `get_input_direction()` - Returns normalized 2D input vector
- `get_move_direction()` - Converts input to 3D movement direction relative to camera
- `can_wallrun()` - Checks if wallrunning conditions are met
- `get_wallrun_normal()` - Returns the normal vector of adjacent wall (for wallrunning)
- `try_interact()` - Attempts to interact with objects in view
- `pause_game()` - Pauses the game and shows pause menu
- `resume_game()` - Resumes the game and hides pause menu
- `toggle_pause()` - Toggles between paused and unpaused
- `take_damage(amount)` - Reduces health by amount
- `heal(amount)` - Increases health by amount
- `use_mana(amount)` - Attempts to use mana, returns success
- `use_stamina(amount)` - Attempts to use stamina, returns success
- `update_hud()` - Updates HUD display with current stats

**Player Stats:**
- `max_health` - Maximum health value (default: 100)
- `max_mana` - Maximum mana value (default: 100)
- `max_stamina` - Maximum stamina value (default: 100)
- `health` - Current health
- `mana` - Current mana
- `stamina` - Current stamina

**Input Flags:**
- `jump_pressed` - Set when jump is pressed this frame
- `dash_pressed` - Set when dash is pressed this frame
- `crouch_pressed` - Set when crouch is pressed this frame

These flags are updated in `_physics_process()` and read by states to determine transitions.

**Game State:**
- `is_paused` - Whether the game is currently paused

**UI References:**
- `hud` - Reference to HUD control node
- `pause_menu` - Reference to PauseMenu control node

### PlayerConfig (player_config.gd)

**Location:** `src/fps/player/player_config.gd`

A Resource class that stores all configurable parameters for player movement and camera behavior. This allows for easy tuning and the creation of different player presets.

**Configuration Categories:**

1. **Movement Speeds:**
   - `walk_speed` (5.0) - Base walking speed
   - `sprint_speed` (8.0) - Sprint speed when holding sprint
   - `crouch_speed` (2.5) - Movement speed while crouching
   - `slide_speed` (10.0) - Initial sliding speed
   - `wallrun_speed` (6.0) - Speed while wallrunning

2. **Jump Settings:**
   - `jump_velocity` (6.0) - Initial jump velocity
   - `min_jump_velocity` (3.0) - Minimum jump height when released early
   - `coyote_time` (0.15) - Time window for jumping after leaving ground

3. **Dash Settings:**
   - `dash_speed` (15.0) - Speed during dash
   - `dash_duration` (0.3) - How long dash lasts

4. **Wallrun Settings:**
   - `wallrun_gravity` (2.0) - Reduced gravity while wallrunning
   - `wallrun_jump_velocity` (8.0) - Vertical velocity when jumping off wall
   - `wallrun_jump_horizontal_velocity` (5.0) - Horizontal velocity away from wall

5. **Physics:**
   - `gravity` (20.0) - Gravity acceleration
   - `acceleration` (10.0) - Ground acceleration
   - `friction` (8.0) - Ground friction
   - `air_acceleration` (3.0) - Air control acceleration

6. **Camera:**
   - `mouse_sensitivity` (0.002) - Mouse look sensitivity
   - `tilt_angle` (5.0) - Maximum head tilt angle in degrees
   - `tilt_speed` (5.0) - Head tilt interpolation speed
   - `base_fov` (75.0) - Default field of view
   - `max_fov` (90.0) - FOV when moving at high speed
   - `fov_speed_threshold` (8.0) - Speed at which FOV starts increasing

7. **Head Bobbing:**
   - `bob_frequency` (2.0) - How fast the head bobs
   - `bob_amplitude` (0.08) - How much the head bobs

8. **Interaction:**
   - `interact_distance` (3.0) - Maximum interaction distance

### CameraController (camera_controller.gd)

**Location:** `src/fps/player/camera_controller.gd`

Handles all camera-related functionality including rotation, tilting, head bobbing, and FOV adjustments.

**Features:**
- Mouse look with vertical clamping (±90 degrees)
- Head tilt on Q/E keys
- Dynamic FOV based on movement speed
- Head bobbing while walking
- Screen shake support (placeholder)

**Key Methods:**
- `rotate_camera(relative: Vector2)` - Handles mouse look rotation
- `update_tilt(delta: float)` - Updates head tilt based on input
- `update_movement(speed: float, delta: float)` - Updates head bobbing
- `update_fov(delta: float)` - Adjusts FOV based on speed
- `shake(intensity: float, duration: float)` - Screen shake (TODO)

**Technical Notes:**
- Horizontal rotation is applied to the CameraPivot node (Y axis)
- Vertical rotation is applied to the Camera3D (X axis)
- Head tilt is applied to the Camera3D (Z axis)
- Mouse is captured on ready

### Hands & Hand System

**Hands (hands.gd):** `src/fps/player/hands.gd`
**Hand (hand.gd):** `src/fps/player/hand.gd`

The hands system manages left and right hand slots for equipping and using items.

**Hand Class:**
- Stores equipped item reference
- Provides `equip_item()` and `unequip_item()` methods
- Calls `attack()` method on equipped items

**Hands Manager:**
- Provides interface for both hands
- Routes input to appropriate hand
- Manages hand-specific operations

**Item Integration:**
Items can be equipped by calling:
```gdscript
player.hands.equip_right_hand(item_instance)
```

Items must implement an `attack()` method to be usable.

## State Machine System

### StateMachine (state_machine.gd)

**Location:** `src/fps/player/state_machine.gd`

The state machine manages player movement states and transitions between them.

**Initialization:**
1. Waits for owner (player) to be ready
2. Registers all child nodes that extend State
3. Passes player and state_machine references to each state
4. Enters the `initial_state` (set in scene to IdleState)

**Operation:**
- `_physics_process()` calls current state's `update()` method
- If update returns a state name, transitions to that state
- `_input()` forwards input events to current state

**Transition Process:**
1. Call `exit()` on current state
2. Switch to new state
3. Call `enter()` on new state

### Base State (state.gd)

**Location:** `src/fps/player/states/state.gd`

All states extend this base class which provides the interface and shared references.

**Properties:**
- `player: CharacterBody3D` - Reference to player
- `state_machine: Node` - Reference to state machine

**Methods:**
- `enter()` - Called when state becomes active
- `exit()` - Called when leaving state
- `update(delta: float) -> String` - Main logic, returns next state name or ""
- `handle_input(event: InputEvent)` - Handles input events

## Individual States

### IdleState

**File:** `src/fps/player/states/idle_state.gd`

Player is standing still on the ground.

**Transitions:**
- → JumpingState: When jump pressed and on floor
- → DashingState: When dash pressed
- → MovingState: When input detected
- → FallingState: When not on floor

**Behavior:**
- Applies gravity
- Applies friction to slow down residual velocity

### MovingState

**File:** `src/fps/player/states/moving_state.gd`

Player is moving on the ground, handles walking, sprinting, and crouching.

**Transitions:**
- → JumpingState: When jump pressed and on floor
- → DashingState: When dash pressed
- → SlidingState: When crouch pressed while moving
- → IdleState: When no input and on floor
- → FallingState: When not on floor

**Behavior:**
- Calculates target speed based on sprint/crouch state
- Sprint only works when moving forward (dot product > 0.7)
- Applies acceleration toward target velocity
- Updates camera for head bobbing

**Local Variables:**
- `is_sprinting: bool` - Whether currently sprinting
- `is_crouching: bool` - Whether currently crouching

### JumpingState

**File:** `src/fps/player/states/jumping_state.gd`

Player is jumping upward.

**Transitions:**
- → DashingState: When dash pressed
- → WallrunningState: When wallrun conditions met
- → FallingState: When velocity.y < 0

**Behavior:**
- Sets initial upward velocity on enter
- Variable jump height: releases jump early reduces velocity
- Limited air control via `air_acceleration`
- Applies gravity

**Local Variables:**
- `jump_released: bool` - Tracks if jump was released early

### FallingState

**File:** `src/fps/player/states/falling_state.gd`

Player is in the air moving downward.

**Transitions:**
- → JumpingState: When jump pressed and coyote timer active
- → DashingState: When dash pressed
- → WallrunningState: When wallrun conditions met
- → MovingState: When landed with input
- → IdleState: When landed without input

**Behavior:**
- Coyote time allows jumping shortly after leaving ground
- Limited air control
- Applies gravity

**Local Variables:**
- `coyote_timer: float` - Countdown for coyote jump window

### DashingState

**File:** `src/fps/player/states/dashing_state.gd`

Player dashes in the direction camera is facing, including vertical component.

**Transitions:**
- → MovingState: When dash ends, on floor, with input
- → IdleState: When dash ends, on floor, no input
- → FallingState: When dash ends, in air

**Behavior:**
- Captures dash direction from camera on enter (including Y component)
- Maintains constant velocity during dash
- Timer controls duration

**Local Variables:**
- `dash_timer: float` - Countdown for dash duration
- `dash_direction: Vector3` - Direction to dash

**Technical Note:**
The dash can move vertically, allowing for aerial movement tricks.

### SlidingState

**File:** `src/fps/player/states/sliding_state.gd`

Player slides along the ground while crouching, carrying momentum.

**Transitions:**
- → MovingState: When crouch released with input, or speed reaches zero with crouch held
- → IdleState: When crouch released with no input
- → FallingState: When not on floor

**Behavior:**
- Captures horizontal velocity direction on enter
- Falls back to camera forward if no momentum
- Applies double friction to slow down
- Exits when speed ≤ 0.1

**Local Variables:**
- `slide_direction: Vector3` - Horizontal direction of slide

**Design Note:**
Slide only activates when MovingState transitions to it (crouch pressed while moving), creating a deliberate momentum-based mechanic.

### WallrunningState

**File:** `src/fps/player/states/wallrunning_state.gd`

Player runs along a wall while in the air.

**Transitions:**
- → JumpingState: When jump pressed (jumps away from wall)
- → FallingState: When wallrun conditions no longer met

**Behavior:**
- Calculates run direction perpendicular to wall
- Applies reduced gravity (slides down slowly)
- Jump launches player away from wall with upward boost
- Continuously updates wall normal

**Local Variables:**
- `wall_normal: Vector3` - Normal vector of wall
- `wallrun_direction: Vector3` - Direction to run along wall

**Technical Details:**

Wallrun activation (in player.gd `can_wallrun()`):
1. Must be in air
2. Must have movement input
3. Must detect wall via left/right raycasts
4. Must not be facing wall directly (dot product > -0.3)

Jump off wall:
- Horizontal velocity: `wall_normal * jump_horizontal_velocity`
- Vertical velocity: `wallrun_jump_velocity`

## Input Actions

The following input actions must be defined in Project Settings → Input Map:

- `forward` - Move forward (W)
- `backward` - Move backward (S)
- `left` - Move left (A)
- `right` - Move right (D)
- `jump` - Jump (Space)
- `dash` - Dash (Shift)
- `crouch` - Crouch (Ctrl)
- `sprint` - Sprint (usually same as Dash)
- `interact` - Interact with objects (E)
- `left_hand` - Use left hand item (Mouse Button 1)
- `right_hand` - Use right hand item (Mouse Button 2)
- `tilt_left` - Tilt head left (Q)
- `tilt_right` - Tilt head right (E)
- `ui_cancel` - Pause/unpause game (Escape) - Built-in Godot action

## Interaction System

The interaction system uses a RayCast3D attached to the camera.

**Setup:**
- RayCast3D extends from Camera3D
- Default distance: 3 units (configurable via `interact_distance`)
- Enabled at all times

**Usage:**
When interact key is pressed:
1. Check if raycast is colliding
2. Get the collider node
3. Check if collider has `interact()` method
4. Call the method if it exists

**Creating Interactable Objects:**

```gdscript
extends StaticBody3D

func interact() -> void:
    print("Player interacted with ", name)
    # Your interaction logic here
```

## Player Stats System

The player has three main stats: health, mana, and stamina.

**Health:**
- Determines player survival
- When health reaches 0, `die()` is called
- Updated via `take_damage()` and `heal()` methods

**Mana:**
- Resource for magical abilities
- Consumed via `use_mana()` which returns false if insufficient
- Restored via `restore_mana()`

**Stamina:**
- Resource for physical abilities (dash, wallrun, etc.)
- Consumed via `use_stamina()` which returns false if insufficient
- Restored via `restore_stamina()`

**HUD Integration:**
All stats automatically update the HUD when changed through the setter methods. The HUD must have an `update_bar(bar_name, current, max)` method.

**Example Usage:**
```gdscript
# Damage player
player.take_damage(25.0)

# Check if player can use mana
if player.use_mana(30.0):
    # Cast spell
    pass

# Regenerate stamina
player.restore_stamina(10.0 * delta)
```

## Pause System

The pause system halts all player input and movement while showing the pause menu.

**How It Works:**
1. Press Escape (ui_cancel) to toggle pause
2. Player sets `is_paused = true` and `get_tree().paused = true`
3. Mouse is released from capture mode
4. Pause menu becomes visible
5. All player input processing stops
6. Camera stops processing
7. State machine stops updating

**Process Mode:**
- Player and children use default process mode
- Pause menu must have `PROCESS_MODE_ALWAYS` to work when paused
- StateMachine, Camera, and Player all check `is_paused` flag

**Resume:**
- From pause menu: call `player.resume_game()`
- Or press Escape again to toggle
- Mouse is captured again
- All systems resume

**Integration:**
The pause menu must set its `player` reference and have:
- `show_main_menu()` method
- `visible` property

## Wallrun System

Wallrunning uses two RayCast3D nodes created at runtime in `player.gd`.

**Setup:**
- Right raycast: points right (1, 0, 0)
- Left raycast: points left (-1, 0, 0)
- Both parented to player

**Detection Logic:**

```gdscript
func can_wallrun() -> bool:
    # Must be airborne
    # Must have input
    # Must detect wall on left or right
    # Must not be facing wall (allows running parallel/away)
```

**Movement:**
- Calculate direction perpendicular to wall normal
- Project camera forward onto wall plane
- Move along wall at `wallrun_speed`
- Apply `wallrun_gravity` (much less than normal)

**Wall Jump:**
- Launches player away from wall
- Adds upward velocity boost
- Transitions to JumpingState

## Performance Considerations

**State Updates:**
- States only run during `_physics_process()` at physics frame rate
- No polling in `_process()` for gameplay logic

**Raycast Optimization:**
- Interaction raycast: always enabled (single cast)
- Wallrun raycasts: always enabled (two casts, minimal overhead)
- All raycasts have reasonable max distances

**Movement Calculations:**
- Direction calculations cached when possible
- Normalization only performed when needed
- Velocity modifications use `move_toward()` for smooth interpolation

## Extending the System

### Adding New States

1. Create new script extending State in `states/` folder
2. Implement `enter()`, `exit()`, and `update()` methods
3. Add state as child node to StateMachine in player.tscn
4. Add transitions from/to the new state in relevant existing states

Example:
```gdscript
extends State

func enter() -> void:
    # Setup state

func update(delta: float) -> String:
    # Check transitions
    # Update movement
    player.move_and_slide()
    return ""  # or return state name to transition

func exit() -> void:
    # Cleanup
```

### Adding New Items

1. Create item scene with visual representation
2. Add script with `attack()` method
3. Equip to hand:

```gdscript
var item = preload("res://path/to/item.tscn").instantiate()
player.hands.equip_right_hand(item)
```

### Modifying Movement Parameters

Create a PlayerConfig resource:
1. In Godot editor: New Resource → PlayerConfig
2. Adjust values in inspector
3. Assign to player's `config` export variable

Or modify in code:
```gdscript
player.config.sprint_speed = 10.0
player.config.jump_velocity = 8.0
```

## Debugging Tips

**View Current State:**
```gdscript
print(player.state_machine.get_current_state_name())
```

**Monitor Velocity:**
```gdscript
func _physics_process(delta):
    print("Velocity: ", player.velocity)
    print("Speed: ", player.velocity.length())
```

**Visualize Raycasts:**
Enable in editor:
- Select RayCast3D nodes
- Set visible in inspector for debugging

**Test State Transitions:**
Add debug prints in state `enter()` and `exit()` methods to track transition flow.

## UI Integration

**HUD Setup:**
The HUD should be a child of CanvasLayer in the player scene at path: `CanvasLayer/HUD`

Required method:
```gdscript
func update_bar(bar: String, current: float, max: float):
    # Update the specified bar (health, mana, or stamina)
```

**Pause Menu Setup:**
The pause menu should be a child of CanvasLayer in the player scene at path: `CanvasLayer/PauseMenu`

Required properties:
- `player: CharacterBody3D` - Set automatically by player
- `visible: bool` - Controlled by pause system
- `process_mode = PROCESS_MODE_ALWAYS` - Required for pause to work

Required methods:
- `show_main_menu()` - Show the main pause menu screen

The pause menu should handle its own button callbacks and call `player.resume_game()` to unpause.

## Common Issues and Solutions

**Issue: Pause menu doesn't work when game is paused**
- Ensure pause menu has `process_mode = Node.PROCESS_MODE_ALWAYS`
- Check that pause menu is at correct path `CanvasLayer/PauseMenu`

**Issue: HUD not updating**
- Verify HUD has `update_bar(bar, current, max)` method
- Check HUD is at correct path `CanvasLayer/HUD`
- Make sure you're using setter methods (`take_damage`, `use_mana`, etc.) not directly modifying stat variables

**Issue: Can't unpause game**
- Verify pause menu calls `player.resume_game()` not just hiding itself
- Check that Escape key is mapped to `ui_cancel` action

**Issue: Player falls through floor**
- Ensure collision layers/masks are set correctly
- Check that StaticBody3D or other floor nodes have collision shapes

**Issue: Wallrun not activating**
- Check raycast collision layers
- Verify walls have collision enabled
- Test with debug visualization of raycasts
- Check dot product threshold in `can_wallrun()`

**Issue: Jump feels floaty**
- Increase `gravity` value
- Decrease `jump_velocity`
- Adjust `air_acceleration` for air control

**Issue: Slide doesn't work**
- Must transition from MovingState (be moving first)
- Check that crouch action is mapped
- Verify initial momentum is sufficient

**Issue: Camera rotation inverted**
- Adjust sign in `camera_controller.gd` `rotate_camera()` method
- Modify `mouse_sensitivity` value (can be negative)

**Issue: State machine not starting**
- Verify `initial_state` is set in StateMachine node
- Check that state nodes are children of StateMachine
- Ensure state scripts extend State class

## File Reference

```
src/fps/player/
├── player.gd                    # Main player controller
├── player.tscn                  # Player scene
├── player_config.gd             # Configuration resource
├── camera_controller.gd         # Camera handling
├── hands.gd                     # Hands manager
├── hand.gd                      # Individual hand
├── state_machine.gd             # State machine controller
└── states/
    ├── state.gd                 # Base state class
    ├── idle_state.gd            # Idle state
    ├── moving_state.gd          # Moving state
    ├── jumping_state.gd         # Jumping state
    ├── falling_state.gd         # Falling state
    ├── dashing_state.gd         # Dashing state
    ├── sliding_state.gd         # Sliding state
    └── wallrunning_state.gd     # Wallrunning state
```

## Version Information

- Godot Version: 4.x
- GDScript Version: 2.0
- Last Updated: 2025-12-26
