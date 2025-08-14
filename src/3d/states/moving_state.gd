extends State
class_name MovingState

## Moving state - handles walking, running, sprinting, and crawling

var current_move_speed: float

func enter():
	print("Entering Moving state")

func exit():
	pass

func physics_update(delta: float):
	# Check for state transitions
	if not player.is_on_floor():
		transition_to("falling")
		return
	
	var input_direction = player.get_movement_input_direction()
	
	# Check if we should stop moving
	if input_direction == Vector3.ZERO:
		transition_to("idle")
		return
	
	# Check for jump
	if player.can_jump():
		player.request_jump()
		transition_to("jumping")
		return
	
	# Check for crouch while moving (crawling)
	if player.is_crouching():
		transition_to("crouching")  # Crouching state will handle crawling
		return
	
	# Check for dash
	if Input.is_action_just_pressed("dash"):
		print("pressed dash")
		if player.request_dash():
			transition_to("dashing")
			return
	
	# Determine movement speed based on sprint input
	if player.is_sprinting():
		current_move_speed = player.move_speed * player.sprint_speed_multiplier
		print("Sprinting at speed: ", current_move_speed)
	else:
		current_move_speed = player.move_speed
	
	# Apply movement
	var target_velocity = input_direction * current_move_speed
	var horizontal_velocity = player.get_horizontal_velocity()
	
	# Smooth movement acceleration
	var acceleration = 15.0 if player.is_on_floor() else 5.0
	horizontal_velocity = horizontal_velocity.move_toward(target_velocity, acceleration * delta)
	
	player.set_horizontal_velocity(horizontal_velocity)

func get_state_name() -> String:
	return "moving"
