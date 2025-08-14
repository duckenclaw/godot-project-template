extends State
class_name WallrunningState

## Wallrunning state - player runs along walls
## Note: This is a basic implementation that would need additional wall detection

var wallrun_timer: float = 0.0
var max_wallrun_time: float = 5.0
var wallrun_speed: float = 10.0
var wallrun_speed_multiplier: float = 0.75
var wall_normal: Vector3
var wallrun_direction: Vector3

func enter():
	print("Entering Wallrunning state")
	wallrun_timer = max_wallrun_time
	
	# TODO: Detect wall and calculate wall normal and run direction
	# For now, use placeholder values
	
	wall_normal = player.get_wall_normal() 
	print("Wall normal: ", wall_normal)
	wallrun_direction = calculate_wallrun_direction()
	print("Wallrun direction: ", wallrun_direction)
	wallrun_speed = player.move_speed * wallrun_speed_multiplier
	
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
		var jump_away_velocity = wall_normal * player.jump_velocity  # Push away from wall
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
	print("Detecting walls: " + str(player.is_on_wall()))
	return player.is_on_wall()

func get_wall_normal() -> Vector3:
	# Implementation needed to get wall surface normal
	return Vector3.RIGHT

func calculate_wallrun_direction() -> Vector3:
	if not player:
		return Vector3.FORWARD
	
	# Get the player's horizontal velocity (ignore Y component)
	var horizontal_velocity = Vector3(player.velocity.x, 0, player.velocity.z)
	
	# If player has no horizontal velocity, use input direction
	if horizontal_velocity.length() < 0.1:
		horizontal_velocity = player.get_movement_input_direction()
		if horizontal_velocity.length() < 0.1:
			# Fallback: use camera forward direction
			horizontal_velocity = -player.camera_pivot.global_transform.basis.z
			horizontal_velocity.y = 0
			horizontal_velocity = horizontal_velocity.normalized()
	
	# Calculate the direction parallel to the wall
	# This is done by projecting the velocity onto the wall plane
	# Wall plane is perpendicular to wall_normal
	var wall_parallel_direction = horizontal_velocity - wall_normal * horizontal_velocity.dot(wall_normal)
	wall_parallel_direction = wall_parallel_direction.normalized()
	
	# Ensure we're running forward along the wall (not backward)
	# Check if the calculated direction aligns with the original movement intent
	var original_direction = horizontal_velocity.normalized()
	if wall_parallel_direction.dot(original_direction) < 0:
		wall_parallel_direction = -wall_parallel_direction
	
	return wall_parallel_direction
