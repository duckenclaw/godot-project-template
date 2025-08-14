extends State
class_name JumpingState

## Jumping state - player is ascending from a jump

var jump_hold_time: float = 0.0
var max_jump_hold_time: float = 0.3
var jump_hold_bonus: float = 0.5

func enter():
	print("Entering Jumping state")
	jump_hold_time = 0.0

func exit():
	pass

func physics_update(delta: float):
	if Input.is_action_pressed("jump") and jump_hold_time < max_jump_hold_time:
		jump_hold_time += delta
		# Apply additional upward force while holding jump
		player.velocity.y += jump_hold_bonus * delta
	
	if player.is_on_wall_only():
		transition_to("wallrunning")
		return
	
	# Check if we're falling (reached peak of jump or released jump early)
	if player.velocity.y <= 0:
		transition_to("falling")
		return
	
	# Handle horizontal movement while in air
	var input_direction = player.get_movement_input_direction()
	if input_direction != Vector3.ZERO:
		var horizontal_velocity = player.get_horizontal_velocity()
		var air_acceleration = 5.0  # Reduced air control
		var target_velocity = input_direction * player.move_speed * 0.8  # Reduced air speed
		
		horizontal_velocity = horizontal_velocity.move_toward(target_velocity, air_acceleration * delta)
		player.set_horizontal_velocity(horizontal_velocity)

func get_state_name() -> String:
	return "jumping"
