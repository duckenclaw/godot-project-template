class_name CameraController
extends Node3D

## Camera controller - handles camera movement, rotation, tilting, head bobbing, and FOV

@onready var camera: Camera3D = $Camera3D
@onready var player: CharacterBody3D = owner

var config: PlayerConfig

# Camera rotation
var rotation_x: float = 0.0
var rotation_y: float = 0.0

# Head tilt
var current_tilt: float = 0.0
var target_tilt: float = 0.0
var tilt_override_active: bool = false
var tilt_override_angle: float = 0.0
var manual_tilt_enabled: bool = true

# Head bobbing
var bob_time: float = 0.0

# FOV
var current_fov: float = 75.0

func _ready() -> void:
	# Capture mouse
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Get config from player
	if player:
		config = player.config
		if config:
			current_fov = config.base_fov
			camera.fov = current_fov

func _input(event: InputEvent) -> void:
	if not config:
		return

	# Don't process input when paused
	if player and player.is_paused:
		return

	# Handle mouse movement
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_camera(event.relative)

func _process(delta: float) -> void:
	if not config:
		return

	# Don't process when paused
	if player and player.is_paused:
		return

	# Update tilt
	update_tilt(delta)

	# Update FOV based on speed
	update_fov(delta)

## Rotate camera based on mouse movement
func rotate_camera(relative: Vector2) -> void:
	# Horizontal rotation (Y axis) - rotate the player body
	rotation_y -= relative.x * config.mouse_sensitivity
	player.rotation.y = rotation_y

	# Vertical rotation (X axis) - rotate the camera
	rotation_x -= relative.y * config.mouse_sensitivity
	rotation_x = clamp(rotation_x, -PI/2, PI/2)
	camera.rotation.x = rotation_x

## Update head tilt based on input
func update_tilt(delta: float) -> void:
	# Check if tilt is being overridden by a state
	if tilt_override_active:
		target_tilt = tilt_override_angle
		# Calculate horizontal offset based on override angle
		var tilt_input = tilt_override_angle / deg_to_rad(config.tilt_angle)
		var target_x_offset = -tilt_input * config.tilt_shift
		camera.position.x = lerp(camera.position.x, target_x_offset, config.tilt_speed * delta)
	elif manual_tilt_enabled:
		# Get tilt input only if manual tilting is enabled
		var tilt_input = 0.0
		if Input.is_action_pressed("tilt_left"):
			tilt_input = 1.0
		elif Input.is_action_pressed("tilt_right"):
			tilt_input = -1.0

		# Update target tilt
		target_tilt = tilt_input * deg_to_rad(config.tilt_angle)

		# Move camera horizontally based on tilt (left tilt = shift left, right tilt = shift right)
		var target_x_offset = -tilt_input * config.tilt_shift
		camera.position.x = lerp(camera.position.x, target_x_offset, config.tilt_speed * delta)
	else:
		# Manual tilt disabled, return to neutral
		target_tilt = 0.0
		camera.position.x = lerp(camera.position.x, 0.0, config.tilt_speed * delta)

	# Smoothly interpolate to target tilt
	current_tilt = lerp(current_tilt, target_tilt, config.tilt_speed * delta)
	camera.rotation.z = current_tilt

## Update head bobbing when moving
func update_movement(speed: float, delta: float) -> void:
	if speed > 0.1 and player.is_on_floor():
		bob_time += delta * config.bob_frequency * speed
		var bob_offset = sin(bob_time) * config.bob_amplitude
		camera.position.y = bob_offset
	else:
		# Return to center
		bob_time = 0
		camera.position.y = lerp(camera.position.y, 0.0, 10.0 * delta)

## Update FOV based on player speed
func update_fov(delta: float) -> void:
	var horizontal_velocity = Vector3(player.velocity.x, 0, player.velocity.z)
	var speed = horizontal_velocity.length()

	# Increase FOV when moving fast
	var target_fov = config.base_fov
	if speed > config.fov_speed_threshold:
		var fov_increase = (speed - config.fov_speed_threshold) / config.fov_speed_threshold
		fov_increase = clamp(fov_increase, 0.0, 1.0)
		target_fov = lerp(config.base_fov, config.max_fov, fov_increase)

	# Smoothly interpolate FOV
	current_fov = lerp(current_fov, target_fov, 5.0 * delta)
	camera.fov = current_fov

## Set tilt override (used by states like wallrunning)
func set_tilt_override(angle_degrees: float) -> void:
	tilt_override_active = true
	tilt_override_angle = deg_to_rad(angle_degrees)

## Clear tilt override and return to normal behavior
func clear_tilt_override() -> void:
	tilt_override_active = false
	tilt_override_angle = 0.0

## Enable manual tilting (default)
func enable_manual_tilt() -> void:
	manual_tilt_enabled = true

## Disable manual tilting
func disable_manual_tilt() -> void:
	manual_tilt_enabled = false

## Screen shake effect
func shake(intensity: float, duration: float) -> void:
	# TODO: Implement screen shake
	pass
