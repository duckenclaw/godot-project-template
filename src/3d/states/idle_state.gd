extends State
class_name IdleState

## Idle state - player is standing still on the ground

func enter():
	print("Entering Idle state")

func exit():
	pass

func physics_update(delta: float):
	if not player.is_on_floor():
		transition_to("falling")
		return
	
	# Check for movement input
	var input_direction = player.get_movement_input_direction()
	if input_direction != Vector3.ZERO:
		transition_to("moving")
		return
	
	# Check for jump
	if player.can_jump():
		player.request_jump()
		transition_to("jumping")
		return
	
	# Check for crouch
	if player.is_crouching():
		transition_to("crouching")
		return
	
	# Apply friction to horizontal movement
	var horizontal_velocity = player.get_horizontal_velocity()
	horizontal_velocity = horizontal_velocity.move_toward(Vector3.ZERO, 50.0 * delta)
	player.set_horizontal_velocity(horizontal_velocity)

func get_state_name() -> String:
	return "idle"
