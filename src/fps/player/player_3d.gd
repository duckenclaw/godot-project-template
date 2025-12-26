extends CharacterBody3D

@export var player_config: PlayerConfig = PlayerConfig.new()

# Movement properties (calculated from player_config)
var move_speed: float
var jump_velocity: float
var dash_distance: float
var sprint_speed_multiplier: float
var max_health: float
var current_health: float
var max_mana: float
var current_mana: float

# Movement state
var input_vector: Vector2
var last_movement_direction: Vector3
var is_on_floor_buffered: bool = false
var coyote_time: float = 0.0
var jump_buffer_time: float = 0.0
var dash_cooldown: float = 0.0
var in_dialogue: bool = false

# Input buffer for combo detection
var input_buffer: Array[String] = []
var input_buffer_timer: float = 0.0

# Constants
const GRAVITY: float = 9.8
const COYOTE_TIME_DURATION: float = 0.1
const JUMP_BUFFER_DURATION: float = 0.2
const DASH_COOLDOWN_DURATION: float = 1.0
const FLOOR_SNAP_LENGTH: float = 0.1

# Input buffer constants
const INPUT_BUFFER_SIZE: int = 10
const INPUT_BUFFER_TIMEOUT: float = 0.5
const CIRCULAR_MOTION_THRESHOLD: int = 4

# Node references
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera_tilt: Node3D = $CameraPivot/CameraTilt
@onready var camera: CameraController = $CameraPivot/CameraTilt/Camera3D
@onready var interaction_raycast: RayCast3D = $CameraPivot/CameraTilt/Camera3D/RayCast3D
@onready var state_machine: StateMachine = $States/StateMachine
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var hud: Control = $UI/HUD
@onready var pause_menu: Control = $UI/PauseMenu
@onready var dialog_menu: Control = $UI/DialogMenu
@onready var hands: Node3D = $CameraPivot/CameraTilt/Camera3D/Hands

# Equipment inventory
@export var available_items: Array[Item] = []

func _ready():
	# Calculate movement properties from config
	update_stats()
	
	# Set player reference in pause menu and dialog menu
	if pause_menu:
		pause_menu.player = self
	if dialog_menu:
		dialog_menu.player = self
	
	# Print config summary
	print("Player initialized with config:")
	print(player_config.get_stats_summary())
	print(player_config.get_flags_summary())

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
	# Skip all player input processing if in dialogue
	if in_dialogue:
		return

	# Track directional inputs for combo system
	track_directional_inputs()

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
		if available_items.size() > 0:
			hands.right_hand.unequip_item()
			hands.right_hand.equip_item(available_items[0])
	if Input.is_action_just_pressed("equip_2"):
		if available_items.size() > 1:
			hands.right_hand.unequip_item()
			hands.right_hand.equip_item(available_items[1])
		else:
			hands.right_hand.unequip_item()
	
	# Handle attacks
	if Input.is_action_just_pressed("attack"):
		hands.use_right_hand()  # Primary attack with right hand
	if Input.is_action_just_pressed("attack_alternate"):
		hands.use_left_hand()   # Alternate attack with left hand
	
	# Handle escape / pause menu
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_pause_menu()

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

	# Input buffer timer - clear buffer if timeout expires
	if input_buffer_timer > 0:
		input_buffer_timer -= delta
	else:
		if input_buffer.size() > 0:
			input_buffer.clear()

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
	if can_jump() and Input.is_action_pressed("jump"):
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
		if collider and collider.has_method("get_dialog"):
			var npc_dialog = collider.get_dialog()
			print("DEBUG: NPC dialog is: ", npc_dialog)
			if npc_dialog:
				if npc_dialog.nodes.is_empty():
					push_error("NPC '" + collider.name + "' has a dialog resource but no dialog nodes!")
					return
				print("DEBUG: Dialog has ", npc_dialog.nodes.size(), " nodes")
				start_dialogue(npc_dialog)
				return
			else:
				print("WARNING: NPC '" + collider.name + "' has no dialog assigned")
		if collider and collider.has_method("use"):
			collider.use()
			print("Interacting with: ", collider.name)
			return

func update_stats():
	move_speed = player_config.speed
	jump_velocity = player_config.jump_height
	dash_distance = player_config.dash_length
	sprint_speed_multiplier = player_config.sprint_multiplier
	
	max_health = player_config.max_health
	current_health = player_config.max_health
	hud.update_bar("health", current_health, max_health)
	max_mana = player_config.max_mana
	current_mana = player_config.max_mana
	hud.update_bar("mana", current_mana, max_mana)

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

func toggle_pause_menu():
	var is_paused = get_tree().paused
	
	if is_paused:
		# Resume game
		resume_game()
	else:
		# Pause game
		pause_game()

func pause_game():
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pause_menu.visible = true
	pause_menu.grab_focus()

func resume_game():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pause_menu.visible = false

func start_dialogue(npc_dialog: DialogResource):
	print("DEBUG: start_dialogue called with dialog: ", npc_dialog)
	print("DEBUG: First node is: ", npc_dialog.nodes[0])

	in_dialogue = true
	hud.visible = false
	dialog_menu.dialog = npc_dialog
	dialog_menu.current_dialog = npc_dialog.nodes[0]
	dialog_menu.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	dialog_menu.start_dialog()

func end_dialogue():
	in_dialogue = false
	hud.visible = true
	dialog_menu.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

## Add directional input to the input buffer
func add_input_to_buffer(input_name: String):
	# Reset timer when new input is added
	input_buffer_timer = INPUT_BUFFER_TIMEOUT

	# Add input to buffer
	input_buffer.append(input_name)

	# Limit buffer size
	if input_buffer.size() > INPUT_BUFFER_SIZE:
		input_buffer.pop_front()

## Detect combo pattern from input buffer
func detect_combo() -> String:
	var buffer_string = "".join(input_buffer)
	var buffer_size = input_buffer.size()

	# Check for circular motion (4 consecutive directional inputs in a circle)
	if buffer_size >= CIRCULAR_MOTION_THRESHOLD:
		var last_four = input_buffer.slice(buffer_size - CIRCULAR_MOTION_THRESHOLD, buffer_size)
		var circular_patterns = ["WASD", "ASDW", "SDWA", "DWAS", "WDSA", "DSAW", "SAWD", "AWDS"]
		for pattern in circular_patterns:
			if "".join(last_four) == pattern:
				return "circularMotion"

	# Check for forward-backward combo
	if buffer_size >= 2:
		var last_two = input_buffer.slice(buffer_size - 2, buffer_size)
		if "".join(last_two) == "WS" or "".join(last_two) == "SW":
			return "forward-backward"


	# Check for single directional input
	if buffer_size >= 1:
		var last_input = input_buffer[buffer_size - 1]
		match last_input:
			"W":
				return "forward"
			"S":
				return "backward"
			"A":
				return "left"
			"D":
				return "right"

	return ""

## Track directional inputs for combo system
func track_directional_inputs():
	if Input.is_action_just_pressed("forward"):
		add_input_to_buffer("W")
	if Input.is_action_just_pressed("backward"):
		add_input_to_buffer("S")
	if Input.is_action_just_pressed("left"):
		add_input_to_buffer("A")
	if Input.is_action_just_pressed("right"):
		add_input_to_buffer("D")
