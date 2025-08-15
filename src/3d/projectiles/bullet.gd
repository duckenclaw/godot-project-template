extends RigidBody3D
class_name Bullet

## Bullet projectile for ranged weapons
## Handles physics, damage, and cleanup

@export var damage: float = 10.0
@export var speed: float = 50.0
@export var lifetime: float = 5.0

signal hit_target(target: Node3D, damage: float, hit_position: Vector3)

var shooter: Node3D = null
var has_hit: bool = false

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var lifetime_timer: Timer = $LifetimeTimer

func _ready():
	contact_monitor = true
	max_contacts_reported = 10
	
	# Connect signals
	body_entered.connect(_on_body_entered)
	
	# Set up lifetime timer
	if not lifetime_timer:
		lifetime_timer = Timer.new()
		add_child(lifetime_timer)
	
	lifetime_timer.wait_time = lifetime
	lifetime_timer.one_shot = true
	lifetime_timer.timeout.connect(_on_lifetime_timeout)
	lifetime_timer.start()
	
	# Add some initial visual effects
	create_trail_effect()

func initialize(p_damage: float, p_speed: float, p_direction: Vector3, p_shooter: Node3D = null):
	damage = p_damage
	speed = p_speed
	shooter = p_shooter
	
	# Set initial velocity
	linear_velocity = p_direction.normalized() * speed
	
	# Orient the bullet to face the direction of travel
	if p_direction != Vector3.ZERO:
		look_at(global_position + p_direction, Vector3.UP)

func _on_body_entered(body: Node):
	if has_hit or body == shooter:
		return
	
	has_hit = true
	
	# Get hit position
	var hit_position = global_position
	
	# Emit hit signal
	hit_target.emit(body, damage, hit_position)
	
	# Apply damage if the target has a damage method
	if body.has_method("take_damage"):
		body.take_damage(damage, hit_position)
	
	# Create hit effect
	create_hit_effect(hit_position)
	
	# Stop the bullet
	linear_velocity = Vector3.ZERO
	set_collision_layer(0)  # Stop colliding with things
	set_collision_mask(0)
	
	# Hide the bullet and clean up after a short delay
	mesh_instance.visible = false
	get_tree().create_timer(0.1).timeout.connect(queue_free)

func _on_lifetime_timeout():
	# Bullet expired without hitting anything
	queue_free()

func create_trail_effect():
	# Simple trail effect - you can enhance this with particles
	var trail = MeshInstance3D.new()
	var trail_mesh = SphereMesh.new()
	trail_mesh.radius = 0.02
	trail_mesh.height = 0.1
	trail.mesh = trail_mesh
	
	# Create a simple material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.YELLOW
	material.emission_enabled = true
	material.emission = Color.YELLOW * 0.5
	trail.material_override = material
	
	add_child(trail)

func create_hit_effect(hit_pos: Vector3):
	# Simple hit effect - you can enhance this with particles
	print("Bullet hit at position: ", hit_pos, " with damage: ", damage)
	
	# You could add:
	# - Particle effects
	# - Sound effects
	# - Decals on surfaces
	# - Screen shake for player hits
