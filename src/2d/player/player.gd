extends CharacterBody2D

# Movement constants
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const JUMP_HOLD_MULTIPLIER = 1.5
const ACCELERATION = 2000.0
const FRICTION = 1500.0

# Coyote time constants
const COYOTE_TIME = 0.1

# Camera smoothing
const CAMERA_SMOOTHING = 5.0
const CAMERA_LOOK_AHEAD = 100.0

# References
@onready var camera: Camera2D = $Camera
@onready var coyote_timer: Timer = $CoyoteTimer

# State variables
var was_on_floor = false
var jump_held = false
var can_coyote_jump = false

# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _on_coyote_timer_timeout():
	can_coyote_jump = false 

func _physics_process(delta):
	handle_gravity(delta)
	handle_jump()
	handle_horizontal_movement(delta)
	update_camera_smoothly(delta)
	
	# Update floor state for coyote time
	update_coyote_time()
	
	move_and_slide()

func handle_gravity(delta):
	# Add gravity only if not on floor or coyote time has expired
	if not is_on_floor() and not can_coyote_jump:
		velocity.y += gravity * delta

func handle_jump():
	# Check if jump was just pressed
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or can_coyote_jump:
			velocity.y = JUMP_VELOCITY
			jump_held = true
			can_coyote_jump = false
			if coyote_timer:
				coyote_timer.stop()
	
	# Handle variable jump height
	if Input.is_action_pressed("jump") and jump_held and velocity.y < 0:
		# Reduce gravity while holding jump for higher jumps
		velocity.y += gravity * (1.0 - JUMP_HOLD_MULTIPLIER) * get_physics_process_delta_time()
	
	# Stop jump hold when button is released or moving downward
	if Input.is_action_just_released("jump") or velocity.y >= 0:
		jump_held = false

func handle_horizontal_movement(delta):
	var direction = Input.get_axis("left", "right")
	
	if direction != 0:
		# Accelerate toward target speed
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
	else:
		# Apply friction when no input
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

func update_coyote_time():
	# Start coyote time when leaving ground
	if was_on_floor and not is_on_floor() and velocity.y > 0:
		can_coyote_jump = true
		if coyote_timer:
			coyote_timer.start(COYOTE_TIME)
	
	# Reset coyote time when landing
	if is_on_floor():
		can_coyote_jump = false
		if coyote_timer:
			coyote_timer.stop()
	
	was_on_floor = is_on_floor()

func update_camera_smoothly(delta):
	if not camera:
		return
	
	# Calculate target position with look-ahead
	var target_offset = Vector2.ZERO
	var horizontal_input = Input.get_axis("left", "right")
	
	if abs(horizontal_input) > 0.1:
		target_offset.x = horizontal_input * CAMERA_LOOK_AHEAD
	
	# Smoothly move camera to target position
	camera.offset = camera.offset.lerp(target_offset, CAMERA_SMOOTHING * delta)

# Utility functions for external scripts
func get_movement_direction() -> float:
	return Input.get_axis("left", "right")
