extends State

## Wallrunning state - player runs along walls

var wall_normal: Vector3
var wallrun_direction: Vector3

func enter() -> void:
	player.set_normal_height()

	# Get wall normal from raycast
	wall_normal = player.get_wallrun_normal()

	# Calculate wallrun direction (perpendicular to wall normal)
	var forward = -player.camera_pivot.global_transform.basis.z
	wallrun_direction = forward - wall_normal * forward.dot(wall_normal)
	wallrun_direction = wallrun_direction.normalized()

	# Set initial wallrun velocity
	player.velocity = wallrun_direction * player.config.wallrun_speed
	player.velocity.y = 0

func update(delta: float) -> String:
	# Check for jump off wall
	if player.jump_pressed:
		# Jump away from wall and slightly upward
		player.velocity = wall_normal * player.config.wallrun_jump_horizontal_velocity
		player.velocity.y = player.config.wallrun_jump_velocity
		return "JumpingState"

	# Check if no longer touching wall or player stopped moving along wall
	if not player.can_wallrun():
		return "FallingState"

	# Update wall normal and direction
	wall_normal = player.get_wallrun_normal()
	var forward = -player.camera_pivot.global_transform.basis.z
	wallrun_direction = forward - wall_normal * forward.dot(wall_normal)
	wallrun_direction = wallrun_direction.normalized()

	# Move along wall
	player.velocity.x = wallrun_direction.x * player.config.wallrun_speed
	player.velocity.z = wallrun_direction.z * player.config.wallrun_speed

	# Apply reduced gravity (slide down slowly)
	player.velocity.y -= player.config.wallrun_gravity * delta

	player.move_and_slide()

	return ""

func exit() -> void:
	pass
