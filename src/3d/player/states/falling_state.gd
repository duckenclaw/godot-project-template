extends State
class_name FallingState

## Falling state - player is descending (not on ground)

func enter():
	print("Entering Falling state")

func exit():
	# Add landing camera shake
	if player and player.camera:
		var fall_speed = abs(player.velocity.y)
		if fall_speed > 5.0:  # Only shake on significant falls
			var shake_intensity = min(fall_speed / 20.0, 0.3)
			player.camera.add_camera_shake(shake_intensity, 0.3)

func physics_update(delta: float):
	# Check if we've landed
	if player.is_on_floor():
		var input_direction = player.get_movement_input_direction()
		if input_direction == Vector3.ZERO:
			transition_to("idle")
		else:
			transition_to("moving")
		return
	
	# Check for jump (coyote time)
	if player.can_jump() and Input.is_action_pressed("jump") and !player.is_on_wall_only():
		player.request_jump()
		transition_to("jumping")
		return
	
	# Handle horizontal movement while falling
	var input_direction = player.get_movement_input_direction()
	if input_direction != Vector3.ZERO:
		var horizontal_velocity = player.get_horizontal_velocity()
		var air_acceleration = 5.0  # Even more reduced air control when falling
		var target_velocity = input_direction * player.move_speed * 0.6  # Reduced air speed
		
		horizontal_velocity = horizontal_velocity.move_toward(target_velocity, air_acceleration * delta)
		player.set_horizontal_velocity(horizontal_velocity)

func get_state_name() -> String:
	return "falling"
