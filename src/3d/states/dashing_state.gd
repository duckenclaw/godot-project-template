extends State
class_name DashingState

## Dashing state - player moves quickly in a direction for a short time

var dash_timer: float = 0.0
var dash_direction: Vector3
var dash_speed: float = 20.0

func enter():
	print("Entering Dashing state")
	dash_timer = player.dash_distance if player else 1.0
	print(dash_timer)
	dash_direction = player.last_movement_direction if player else Vector3.FORWARD
	
	# Add camera shake for dash
	if player and player.camera:
		player.camera.add_camera_shake(0.15, 0.3)
	
	# Set dash velocity
	if player:
		var dash_velocity = dash_direction * dash_speed
		player.set_horizontal_velocity(dash_velocity)

func exit():
	pass

func physics_update(delta: float):
	dash_timer -= delta
	
	# End dash when timer expires
	if dash_timer <= 0:
		# Transition based on current state
		if not player.is_on_floor():
			transition_to("falling")
		else:
			var input_direction = player.get_movement_input_direction()
			if input_direction == Vector3.ZERO:
				transition_to("idle")
			else:
				transition_to("moving")
		return
	
	# Maintain dash velocity (ignore input during dash)
	var dash_velocity = dash_direction * dash_speed
	player.set_horizontal_velocity(dash_velocity)
	
	# Check if we've left the ground during dash
	if not player.is_on_floor():
		transition_to("falling")
		return

func get_state_name() -> String:
	return "dashing"
