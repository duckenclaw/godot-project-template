extends CharacterBody3D

## Third-person character controller with node-based state machine
## Handles movement, physics, and interactions

@export var player_config: PlayerConfig = PlayerConfig.new()

# Movement properties (calculated from player_config)
var move_speed: float
var jump_velocity: float
var dash_distance: float
var sprint_speed_multiplier: float

# Movement state
var input_vector: Vector2
var last_movement_direction: Vector3
var is_on_floor_buffered: bool = false
var coyote_time: float = 0.0
var jump_buffer_time: float = 0.0
var dash_cooldown: float = 0.0

# Constants
const GRAVITY: float = 9.8
const COYOTE_TIME_DURATION: float = 0.1
const JUMP_BUFFER_DURATION: float = 0.2
const DASH_COOLDOWN_DURATION: float = 1.0
const FLOOR_SNAP_LENGTH: float = 0.1

# Node references
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: CameraController = $CameraPivot/Camera3D
@onready var interaction_raycast: RayCast3D = $CameraPivot/Camera3D/RayCast3D
@onready var state_machine: StateMachine = $States/StateMachine
@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready():
	# Add player to group for easy reference
	add_to_group("player")
	
	# Calculate movement properties from config
	update_movement_properties()
	
	# Print config summary
	print("Player initialized with config:")
	print(player_config.get_stats_summary())

func _physics_process(delta:
float):
	handle_gravity(delta)
	handle_input()
	handle_timers(delta)
	
	# Let the state machine handle movement
	# States will modify velocity as needed
	
	move_and_slide()
	
	# Update floor detection with buffer
	update_floor_detection()

func handle_gravity(delta: float):
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

func handle_input():
	# Get movement input
	input_vector = Vector2.ZERO
	if Input.is_action_pressed("forward"):
		input_vector.y -= 1
	if Input.is_action_pressed("backward"):
		input_vector.y += 1
	if Input.is_action_pressed("left"):
		input_vector.x -= 1
	if Input.is_action_pressed("right"):
		input_vector.x += 1
	
	input_vector = input_vector.normalized()
	
	# Handle jump input with buffer
	if Input.is_action_just_pressed("jump"):
		jump_buffer_time = JUMP_BUFFER_DURATION
	
	# Handle dash input
	if Input.is_action_just_pressed("dash"):
		request_dash()
	
	# Handle interaction
	if Input.is_action_just_pressed("activate"):
		try_interact()
	
	# Handle escape
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func handle_timers(delta: float):
	# Coyote time
	if coyote_time > 0:
		coyote_time -= delta
	
	# Jump buffer
	if jump_buffer_time > 0:
		jump_buffer_time -= delta
	
	# Dash cooldown
	if dash_cooldown > 0:
		dash_cooldown -= delta

func update_floor_detection():
	var was_on_floor = is_on_floor_buffered
	is_on_floor_buffered = is_on_floor()
	
	# Start coyote time when leaving the floor
	if was_on_floor and not is_on_floor_buffered:
		coyote_time = COYOTE_TIME_DURATION

func get_movement_input_direction() -> Vector3:
	if input_vector == Vector2.ZERO:
		return Vector3.ZERO
	
	# Convert 2D input to 3D world direction relative to camera
	var cam_transform = camera_pivot.global_transform
	var forward = -cam_transform.basis.z
	var right = cam_transform.basis.x
	
	# Project onto horizontal plane
	forward.y = 0
	right.y = 0
	forward = forward.normalized()
	right = right.normalized()
	
	var direction = (forward * -input_vector.y + right * input_vector.x).normalized()
	
	# Store last movement direction for dash
	if direction != Vector3.ZERO:
		last_movement_direction = direction
	
	return direction

func can_jump() -> bool:
	return (is_on_floor_buffered or coyote_time > 0) and jump_buffer_time > 0

func request_jump():
	if can_jump():
		velocity.y = jump_velocity
		jump_buffer_time = 0
		coyote_time = 0
		# Add camera shake for jump
		if camera:
			camera.add_camera_shake(0.1, 0.2)

func request_dash():
	if last_movement_direction != Vector3.ZERO:
		dash_cooldown = DASH_COOLDOWN_DURATION
		# States will handle the actual dash movement
		return true
	return false

func try_interact():
	if interaction_raycast.is_colliding():
		var collider = interaction_raycast.get_collider()
		if collider and collider.has_method("use"):
			collider.use()
			print("Interacting with: ", collider.name)

func update_movement_properties():
	move_speed = player_config.speed
	jump_velocity = player_config.jump_height
	dash_distance = player_config.dash_length
	sprint_speed_multiplier = player_config.sprint_multiplier

func get_current_state_name() -> String:
	if state_machine:
		return state_machine.get_current_state_name()
	return "none"

# Helper functions for states
func is_sprinting() -> bool:
	return Input.is_action_pressed("sprint") and Input.is_action_pressed("forward") and is_on_floor()

func is_crouching() -> bool:
	return Input.is_action_pressed("crouch")  # Note: crouch action not defined in project.godot yet

func get_horizontal_velocity() -> Vector3:
	return Vector3(velocity.x, 0, velocity.z)

func set_horizontal_velocity(horizontal_vel: Vector3):
	velocity.x = horizontal_vel.x
	velocity.z = horizontal_vel.z
