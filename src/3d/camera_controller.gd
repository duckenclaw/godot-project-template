extends Camera3D
class_name CameraController

## Camera controller for third-person character with walking sway, shake, and FOV effects

@export_group("Camera Settings")
@export var mouse_sensitivity: float = 0.002
@export var min_pitch: float = -89.0
@export var max_pitch: float = 89.0
@export var base_fov: float = 75.0

@export_group("Walking Sway")
@export var sway_enabled: bool = true
@export var sway_intensity: float = 0.02
@export var sway_frequency: float = 2.0
@export var vertical_sway_intensity: float = 0.01

@export_group("Camera Shake")
@export var shake_enabled: bool = true
@export var shake_decay: float = 5.0

@export_group("Speed FOV")
@export var speed_fov_enabled: bool = true
@export var max_speed_fov_bonus: float = 10.0
@export var speed_fov_smoothing: float = 5.0

# Camera rotation
var pitch: float = 0.0
var yaw: float = 0.0

# Walking sway
var sway_time: float = 0.0
var base_position: Vector3

# Camera shake
var shake_intensity: float = 0.0
var shake_timer: float = 0.0

# Speed FOV
var current_speed: float = 0.0
var target_fov: float

@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var camera_pivot: Node3D = get_parent()

func _ready():
	base_position = position
	target_fov = base_fov
	fov = base_fov
	
	# Capture mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		handle_mouse_look(event.relative)

func _process(delta: float):
	update_camera_effects(delta)

func handle_mouse_look(relative_motion: Vector2):
	# Horizontal rotation (yaw) - rotate the camera pivot
	yaw -= relative_motion.x * mouse_sensitivity
	camera_pivot.rotation.y = yaw
	
	# Vertical rotation (pitch) - rotate the camera itself
	pitch -= relative_motion.y * mouse_sensitivity
	pitch = clamp(pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
	rotation.x = pitch

func update_camera_effects(delta: float):
	if not player:
		return
	
	var velocity = player.velocity
	current_speed = velocity.length()
	
	# Calculate final position with all effects
	var final_position = base_position
	
	# Walking sway effect
	if sway_enabled and current_speed > 0.1:
		final_position += calculate_walking_sway(delta, current_speed)
	
	# Camera shake effect
	if shake_enabled and shake_intensity > 0:
		final_position += calculate_camera_shake(delta)
	
	position = final_position
	
	# Speed-based FOV changes
	if speed_fov_enabled:
		update_speed_fov(delta, current_speed)

func calculate_walking_sway(delta: float, speed: float) -> Vector3:
	sway_time += delta * sway_frequency * (speed / 5.0)  # Adjust frequency based on speed
	
	var horizontal_sway = sin(sway_time) * sway_intensity
	var vertical_sway = sin(sway_time * 2.0) * vertical_sway_intensity
	
	# Apply sway relative to camera's local axes
	var sway_offset = Vector3.ZERO
	sway_offset += transform.basis.x * horizontal_sway
	sway_offset += transform.basis.y * vertical_sway
	
	return sway_offset

func calculate_camera_shake(delta: float) -> Vector3:
	shake_timer -= delta
	
	if shake_timer <= 0:
		shake_intensity = max(0, shake_intensity - shake_decay * delta)
		if shake_intensity <= 0:
			return Vector3.ZERO
	
	var shake_offset = Vector3(
		randf_range(-shake_intensity, shake_intensity),
		randf_range(-shake_intensity, shake_intensity),
		randf_range(-shake_intensity, shake_intensity)
	)
	
	return shake_offset

func update_speed_fov(delta: float, speed: float):
	# Calculate target FOV based on speed
	var speed_ratio = clamp(speed / 20.0, 0.0, 1.0)  # Normalize speed (20 is max expected speed)
	target_fov = base_fov + (max_speed_fov_bonus * speed_ratio)
	
	# Smoothly interpolate to target FOV
	fov = lerp(fov, target_fov, speed_fov_smoothing * delta)

func add_camera_shake(intensity: float, duration: float = 0.5):
	shake_intensity = max(shake_intensity, intensity)
	shake_timer = max(shake_timer, duration)

func set_mouse_sensitivity(new_sensitivity: float):
	mouse_sensitivity = new_sensitivity

func toggle_mouse_capture():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
