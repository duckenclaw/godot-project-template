extends State
class_name CrouchingState

## Crouching state - player is crouched (can be stationary or crawling)

var crouch_speed_multiplier: float = 0.3
var is_crawling: bool = false

func enter():
	print("Entering Crouching state")
	# TODO: Modify collision shape to be shorter when crouching
	# This would require adjusting the CollisionShape3D height

func exit():
	# TODO: Restore collision shape to normal height
	pass

func physics_update(delta: float):
	# Check if we should stop crouching
	if not player.is_crouching():
		# Check if we have room to stand up
		if can_stand_up():
			var input_direction = player.get_movement_input_direction()
			if input_direction == Vector3.ZERO:
				transition_to("idle")
			else:
				transition_to("moving")
			return
	
	# Check for state transitions
	if not player.is_on_floor():
		transition_to("falling")
		return
	
	# Check for jump (crouched jump is lower)
	if player.can_jump():
		player.velocity.y = player.jump_velocity * 0.7  # Reduced jump height when crouched
		player.jump_buffer_time = 0
		player.coyote_time = 0
		transition_to("jumping")
		return
	
	# Handle movement (crawling)
	var input_direction = player.get_movement_input_direction()
	if input_direction != Vector3.ZERO:
		is_crawling = true
		var target_velocity = input_direction * player.move_speed * crouch_speed_multiplier
		var horizontal_velocity = player.get_horizontal_velocity()
		
		# Slower acceleration when crawling
		var acceleration = 8.0
		horizontal_velocity = horizontal_velocity.move_toward(target_velocity, acceleration * delta)
		player.set_horizontal_velocity(horizontal_velocity)
	else:
		is_crawling = false
		# Apply friction when not moving
		var horizontal_velocity = player.get_horizontal_velocity()
		horizontal_velocity = horizontal_velocity.move_toward(Vector3.ZERO, 10.0 * delta)
		player.set_horizontal_velocity(horizontal_velocity)

func can_stand_up() -> bool:
	# TODO: Implement ceiling check to see if player can stand up
	# For now, always return true
	return true

func get_state_name() -> String:
	if is_crawling:
		return "crawling"
	return "crouching"
