extends Control
class_name Crosshair

## Crosshair UI for aiming ranged weapons
## Shows/hides based on equipped weapon and provides visual feedback

@export var crosshair_size: float = 20.0
@export var crosshair_thickness: float = 2.0
@export var crosshair_gap: float = 5.0
@export var crosshair_color: Color = Color.WHITE
@export var crosshair_color_no_ammo: Color = Color.RED

var is_visible: bool = false
var has_ranged_weapon: bool = false
var can_shoot: bool = true

@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")

func _ready():
	# Start hidden
	visible = false
	
	# Connect to player hands if available
	if player:
		setup_hand_connections()

func setup_hand_connections():
	# Connect to hand signals for equipment changes
	if player.left_hand:
		player.left_hand.item_equipped.connect(_on_item_equipped)
		player.left_hand.item_unequipped.connect(_on_item_unequipped)
	if player.right_hand:
		player.right_hand.item_equipped.connect(_on_item_equipped)
		player.right_hand.item_unequipped.connect(_on_item_unequipped)

func _on_item_equipped(item: Item):
	update_crosshair_visibility()

func _on_item_unequipped(item: Item):
	update_crosshair_visibility()

func update_crosshair_visibility():
	if not player:
		return
	
	# Check if either hand has a ranged weapon
	has_ranged_weapon = false
	can_shoot = false
	
	var left_item = player.left_hand.get_equipped_item() if player.left_hand else null
	var right_item = player.right_hand.get_equipped_item() if player.right_hand else null 
	
	if (left_item or right_item) and (left_item.category == "ranged" or right_item.category == "ranged"):
		print("equipped ranged weapon")
		has_ranged_weapon = true
		if right_item.category == "ranged":
			can_shoot = right_item.can_fire()
		else:
			can_shoot = left_item.can_fire()
	
	visible = has_ranged_weapon
	queue_redraw()

func _process(_delta: float):
	# Update crosshair state every frame for ammo changes
	if has_ranged_weapon:
		print(has_ranged_weapon)
		var old_can_shoot = can_shoot
		update_crosshair_visibility()
		if old_can_shoot != can_shoot:
			queue_redraw()

func _draw():
	if not visible or not has_ranged_weapon:
		return
	
	var center = size / 2
	var color = crosshair_color if can_shoot else crosshair_color_no_ammo
	
	# Draw horizontal line (left and right)
	draw_line(
		Vector2(center.x - crosshair_size - crosshair_gap, center.y),
		Vector2(center.x - crosshair_gap, center.y),
		color, crosshair_thickness
	)
	draw_line(
		Vector2(center.x + crosshair_gap, center.y),
		Vector2(center.x + crosshair_size + crosshair_gap, center.y),
		color, crosshair_thickness
	)
	
	# Draw vertical line (top and bottom)
	draw_line(
		Vector2(center.x, center.y - crosshair_size - crosshair_gap),
		Vector2(center.x, center.y - crosshair_gap),
		color, crosshair_thickness
	)
	draw_line(
		Vector2(center.x, center.y + crosshair_gap),
		Vector2(center.x, center.y + crosshair_size + crosshair_gap),
		color, crosshair_thickness
	)

func get_crosshair_world_position() -> Vector3:
	var camera = player.camera
	var screen_center = get_viewport().get_visible_rect().size / 2
	var ray_origin = camera.project_ray_origin(screen_center)
	var ray_direction = camera.project_ray_normal(screen_center)
	
	# Cast a ray to find what we're aiming at
	var space_state = player.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_direction * 1000)
	query.exclude = [player]  # Don't hit the player
	
	var result = space_state.intersect_ray(query)
	if result:
		return result.position
	else:
		# If no hit, return a point far in front of the camera
		return ray_origin + ray_direction * 100

func show_crosshair():
	visible = true

func hide_crosshair():
	visible = false
