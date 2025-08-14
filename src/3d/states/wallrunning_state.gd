extends State
class_name WallrunningState

## Wallrunning state - player runs along walls
## Note: This is a basic implementation that would need additional wall detection

var wallrun_timer: float = 0.0
var max_wallrun_time: float = 5.0
var wallrun_speed: float = 12.0
var wall_normal: Vector3
var wallrun_direction: Vector3

func enter():
	print("Entering Wallrunning state")
	wallrun_timer = max_wallrun_time
	
	# TODO: Detect wall and calculate wall normal and run direction
	# For now, use placeholder values
	wall_normal = Vector3.RIGHT  # Placeholder
	wallrun_direction = Vector3.FORWARD  # Placeholder
	
	# Add camera shake for wallrun start
	if player and player.camera:
		player.camera.add_camera_shake(0.1, 0.2)

func exit():
	pass

func physics_update(delta: float):
	wallrun_timer -= delta
	
	# End wallrun when timer expires or player releases movement
	var input_direction = player.get_movement_input_direction()
	if wallrun_timer <= 0 or input_direction == Vector3.ZERO:
		transition_to("falling")
		return
	
	# Check for jump off wall
	if player.can_jump():
		# Jump away from wall
		player.velocity.y = player.jump_velocity
		var jump_away_velocity = wall_normal * 8.0  # Push away from wall
		player.set_horizontal_velocity(jump_away_velocity)
		player.jump_buffer_time = 0
		player.coyote_time = 0
		transition_to("jumping")
		return
	
	# TODO: Implement proper wall detection and movement
	# For now, just maintain forward movement
	var wallrun_velocity = wallrun_direction * wallrun_speed
	player.set_horizontal_velocity(wallrun_velocity)
	
	# Slight upward force to counteract gravity
	player.velocity.y = max(player.velocity.y, -2.0)

func get_state_name() -> String:
	return "wallrunning"

# TODO: Add wall detection functions
func detect_wall() -> bool:
	# Implementation needed for wall detection using raycasts
	return false

func get_wall_normal() -> Vector3:
	# Implementation needed to get wall surface normal
	return Vector3.RIGHT
