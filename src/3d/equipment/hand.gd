extends Node3D
class_name Hand

## Hand class for managing equipment and actions
## Each hand can hold one item and perform actions independently

signal item_equipped(item: Item)
signal item_unequipped(item: Item)
signal action_performed(action_type: String, item: Item)
signal projectile_fired(projectile_scene: PackedScene, spawn_position: Vector3, direction: Vector3, projectile_data: Dictionary)

@export var hand_side: String = "left"  # "left" or "right"
@export var is_dominant: bool = false   # Dominant hand for two-handed weapons

var equipped_item: Item = null
var is_busy: bool = false
var action_cooldown: float = 0.0

@onready var item_holder: Node3D = $ItemHolder
@onready var mesh_instance: MeshInstance3D = $ItemHolder/MeshInstance3D

# For storing instantiated scene models
var current_model_instance: Node3D = null

# Projectile system
@export var bullet_scene: PackedScene = preload("res://src/3d/projectiles/bullet.tscn")
@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")
@export var anim_player: AnimationPlayer

func _ready():
	# Initialize mesh instance if it doesn't exist
	if not mesh_instance:
		mesh_instance = MeshInstance3D.new()
		if not item_holder:
			item_holder = Node3D.new()
			add_child(item_holder)
		item_holder.add_child(mesh_instance)

func _process(delta: float):
	if action_cooldown > 0:
		action_cooldown -= delta
		if action_cooldown <= 0:
			is_busy = false

func can_equip(item: Item) -> bool:
	if not item:
		return false
	
	# Check if hand is available
	if equipped_item != null:
		return false
	
	# Check if it's a two-handed weapon and we need the dominant hand
	if item.is_two_handed and not is_dominant:
		return false
	
	return true

func equip_item(item: Item) -> bool:
	if not can_equip(item):
		return false
	
	equipped_item = item
	update_visual()
	item_equipped.emit(item)
	
	print("Equipped %s in %s hand" % [item.get_display_name(), hand_side])
	return true

func unequip_item() -> Item:
	var old_item = equipped_item
	if old_item:
		equipped_item = null
		clear_visual()
		item_unequipped.emit(old_item)
		print("Unequipped %s from %s hand" % [old_item.get_display_name(), hand_side])
	return old_item

func has_item() -> bool:
	return equipped_item != null

func get_equipped_item() -> Item:
	return equipped_item

func is_available() -> bool:
	return not is_busy and action_cooldown <= 0

func can_perform_action() -> bool:
	return has_item() and is_available()

func perform_action(action_type: String = "primary") -> bool:
	if not can_perform_action():
		return false
	
	var success = false
	
	match action_type:
		"primary":
			success = perform_primary_action()
		"secondary":
			success = perform_secondary_action()
		_:
			print("Unknown action type: ", action_type)
			return false
	
	if success:
		action_performed.emit(action_type, equipped_item)
	
	return success

func perform_primary_action() -> bool:
	if not equipped_item:
		return false
	
	match equipped_item.category:
		"melee":
			return perform_melee_attack()
		"ranged":
			return perform_ranged_attack()
		_:
			print("Unknown item category for action: ", equipped_item.category)
			return false

func perform_secondary_action() -> bool:
	if not equipped_item:
		return false
	
	match equipped_item.category:
		"melee":
			return perform_melee_block()  # Or alternative attack
		"ranged":
			return perform_ranged_reload()
		_:
			return false

func perform_melee_attack() -> bool:
	var melee_weapon = equipped_item as MeleeWeapon
	if not melee_weapon:
		return false
	
	# Set cooldown based on weapon speed
	action_cooldown = 1.0 / melee_weapon.speed
	is_busy = true
	
	# TODO: Play animation "attack"
	var attack = ["slash_right", "slash_left", "thrust"].pick_random()
	anim_player.play(attack)
	print("Performing melee attack with %s (damage: %.1f)" % [melee_weapon.get_display_name(), melee_weapon.get_max_damage()])
	
	return true

func perform_melee_block() -> bool:
	var melee_weapon = equipped_item as MeleeWeapon
	if not melee_weapon:
		return false
	
	action_cooldown = 0.5  # Block cooldown
	is_busy = true
	
	print("Blocking with %s" % melee_weapon.get_display_name())
	return true

func perform_ranged_attack() -> bool:
	var ranged_weapon = equipped_item as RangedWeapon
	if not ranged_weapon:
		return false
	
	if not ranged_weapon.can_fire():
		print("Cannot fire: out of ammo or reloading")
		return false
	
	# Fire the weapon
	ranged_weapon.fire()
	action_cooldown = ranged_weapon.get_time_between_shots()
	is_busy = true
	
	# Spawn projectile
	spawn_projectile(ranged_weapon)
	
	print("Fired %s (%s remaining)" % [ranged_weapon.get_display_name(), ranged_weapon.get_ammo_text()])
	return true

func perform_ranged_reload() -> bool:
	var ranged_weapon = equipped_item as RangedWeapon
	if !ranged_weapon.needs_reload():
		return false
	
	if ranged_weapon.is_magazine_full():
		print("Magazine already full")
		return false
	
	if ranged_weapon.is_reloading:
		print("Already reloading")
		return false
	
	ranged_weapon.start_reload()
	anim_player.play("reload")
	action_cooldown = ranged_weapon.reload_time
	is_busy = true
	
	print("Reloading %s..." % ranged_weapon.get_display_name())
	
	# Finish reload after cooldown
	get_tree().create_timer(ranged_weapon.reload_time).timeout.connect(finish_reload)
	
	return true

func finish_reload():
	if equipped_item and equipped_item is RangedWeapon:
		var ranged_weapon = equipped_item as RangedWeapon
		ranged_weapon.finish_reload()
		print("Reload complete: %s" % ranged_weapon.get_ammo_text())

func update_visual():
	# Clear any existing visuals first
	clear_visual()
	
	if not equipped_item or not equipped_item.has_model():
		return
	
	if equipped_item.is_scene_model():
		# Handle PackedScene (.glb files)
		var scene_instance = equipped_item.model_scene.instantiate()
		if scene_instance:
			item_holder.add_child(scene_instance)
			current_model_instance = scene_instance
			print("Instantiated scene model: ", equipped_item.get_display_name())
	elif equipped_item.is_mesh_model():
		# Handle Mesh resources
		if mesh_instance:
			mesh_instance.mesh = equipped_item.model_mesh
			mesh_instance.visible = true
			print("Applied mesh model: ", equipped_item.get_display_name())

func clear_visual():
	# Clear scene instance
	if current_model_instance:
		current_model_instance.queue_free()
		current_model_instance = null
	
	# Clear mesh instance
	if mesh_instance:
		mesh_instance.mesh = null
		mesh_instance.visible = false

func get_status_text() -> String:
	if not has_item():
		return "%s hand: Empty" % hand_side.capitalize()
	
	var status = "%s hand: %s" % [hand_side.capitalize(), equipped_item.get_display_name()]
	
	if is_busy:
		status += " (Busy)"
	elif action_cooldown > 0:
		status += " (Cooldown: %.1fs)" % action_cooldown
	
	return status

func spawn_projectile(ranged_weapon: RangedWeapon):
	if not bullet_scene or not player:
		print("Missing bullet scene or player reference")
		return
	
	# Get shooting position (from the weapon/hand position)
	var shoot_position = global_position
	if current_model_instance:
		# If we have a weapon model, shoot from its position
		shoot_position = current_model_instance.global_position
	
	# Get aim direction with accuracy spread
	var aim_direction = get_aim_direction_with_spread(ranged_weapon)
	
	# Create projectile data
	var projectile_data = {
		"damage": ranged_weapon.damage,
		"speed": 50.0,  # Base bullet speed
		"shooter": player,
		"weapon_name": ranged_weapon.get_display_name()
	}
	
	# Emit signal for projectile spawning (player will handle the actual spawning)
	projectile_fired.emit(bullet_scene, shoot_position, aim_direction, projectile_data)

func get_aim_direction_with_spread(ranged_weapon: RangedWeapon) -> Vector3:
	if not player or not player.camera:
		return Vector3.FORWARD
	
	# Get base aim direction (towards crosshair/screen center)
	var camera = player.camera
	var screen_center = get_viewport().get_visible_rect().size / 2
	var ray_origin = camera.project_ray_origin(screen_center)
	var base_direction = camera.project_ray_normal(screen_center)
	
	# Apply accuracy-based spread
	var accuracy = ranged_weapon.accuracy
	var max_spread = deg_to_rad(10.0)  # Maximum spread in radians
	var spread_amount = max_spread * (1.0 - accuracy)  # Lower accuracy = more spread
	
	# Add random spread
	var spread_x = randf_range(-spread_amount, spread_amount)
	var spread_y = randf_range(-spread_amount, spread_amount)
	
	# Apply spread to the direction
	var spread_direction = base_direction
	
	# Create a rotation basis to apply spread
	var up = Vector3.UP
	var right = base_direction.cross(up).normalized()
	var actual_up = right.cross(base_direction).normalized()
	
	# Apply spread rotation
	spread_direction = spread_direction.rotated(right, spread_y)
	spread_direction = spread_direction.rotated(actual_up, spread_x)
	
	return spread_direction.normalized()
