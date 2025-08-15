extends CharacterBody3D

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

# Hand system for equipment
@onready var left_hand: Hand = $CameraPivot/Camera3D/Hands/LeftHand
@onready var right_hand: Hand = $CameraPivot/Camera3D/Hands/RightHand

# Equipment inventory
@export var available_items: Array[Item] = []

func _ready():
	# Add player to group for easy reference
	add_to_group("player")
	
	# Calculate movement properties from config
	update_movement_properties()
	
	# Initialize hand system
	setup_hands()
	
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
	
	# Handle equipment
	if Input.is_action_just_pressed("equip_1"):
		equip_item_by_index(0, true)  # Equip first weapon to right hand
	if Input.is_action_just_pressed("equip_2"):
		equip_item_by_index(1, true)  # Equip second weapon to right hand
	
	# Handle attacks
	if Input.is_action_just_pressed("attack"):
		use_right_hand()  # Primary attack with right hand
	if Input.is_action_just_pressed("attack_alternate"):
		use_left_hand()   # Alternate attack with left hand
	
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
	return ((is_on_floor_buffered or coyote_time > 0) and jump_buffer_time > 0) or is_on_wall_only()
	

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
		# States handle the actual dash movement
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
	return Input.is_action_pressed("crouch") 

func get_horizontal_velocity() -> Vector3:
	return Vector3(velocity.x, 0, velocity.z)

func set_horizontal_velocity(horizontal_vel: Vector3):
	velocity.x = horizontal_vel.x
	velocity.z = horizontal_vel.z

# EQUIPMENT SYSTEM
func setup_hands():
	if left_hand:
		left_hand.hand_side = "left"
		left_hand.is_dominant = false
		left_hand.projectile_fired.connect(_on_projectile_fired)
	if right_hand:
		right_hand.hand_side = "right"
		right_hand.is_dominant = true  # Right hand is dominant for two-handed weapons
		right_hand.projectile_fired.connect(_on_projectile_fired)

func equip_item_to_hand(item: Item, hand: Hand) -> bool:
	print("Equipping" + item.get_display_name() + " to " + hand.hand_side + " hand.")
	if not item or not hand:
		return false
	
	# Check if it's a two-handed weapon
	if item.is_two_handed:
		# Unequip both hands first
		if left_hand.has_item():
			left_hand.unequip_item()
		if right_hand.has_item():
			right_hand.unequip_item()
		
		# Equip to dominant hand only
		if right_hand.is_dominant:
			return right_hand.equip_item(item)
		else:
			return left_hand.equip_item(item)
	else:
		# Single-handed weapon
		return hand.equip_item(item)

func equip_item_by_index(index: int, prefer_right_hand: bool = true) -> bool:
	if index < 0 or index >= available_items.size():
		print("Invalid item index: %d" % index)
		return false
	
	var item = available_items[index]
	var target_hand = right_hand if prefer_right_hand else left_hand
	
	# If preferred hand is occupied, try the other hand
	if not target_hand.can_equip(item):
		target_hand = left_hand if prefer_right_hand else right_hand
	
	return equip_item_to_hand(item, target_hand)

func use_left_hand():
	if left_hand and left_hand.can_perform_action():
		left_hand.perform_action("primary")

func use_right_hand():
	if right_hand and right_hand.can_perform_action():
		right_hand.perform_action("primary")

func get_hands_status() -> String:
	var status = []
	if left_hand:
		status.append(left_hand.get_status_text())
	if right_hand:
		status.append(right_hand.get_status_text())
	return "\n".join(status)

func _on_projectile_fired(projectile_scene: PackedScene, spawn_position: Vector3, direction: Vector3, projectile_data: Dictionary):
	# Spawn the projectile in the world
	if not projectile_scene:
		print("No projectile scene provided")
		return
	
	var projectile = projectile_scene.instantiate()
	if not projectile:
		print("Failed to instantiate projectile")
		return
	
	# Add to the scene tree
	get_tree().current_scene.add_child(projectile)
	
	# Set position
	projectile.global_position = spawn_position
	
	# Initialize the projectile with data
	if projectile.has_method("initialize"):
		projectile.initialize(
			projectile_data.get("damage", 10.0),
			projectile_data.get("speed", 50.0),
			direction,
			projectile_data.get("shooter", self)
		)
	
	print("Fired projectile from %s" % projectile_data.get("weapon_name", "unknown weapon"))
