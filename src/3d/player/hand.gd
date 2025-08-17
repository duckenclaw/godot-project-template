extends Node3D
class_name Hand

## Hand class for managing equipment and actions
## Each hand can hold one item and perform actions independently

@export var hand_side: String = "left"  # "left" or "right"
@export var is_dominant: bool = false   # Dominant hand for two-handed weapons

var equipped_item: Item = null
var is_busy: bool = false
var action_cooldown: float = 0.0

@onready var item_holder: Node3D = $ItemHolder

# For storing instantiated scene models
var current_model_instance: Node3D = null

@onready var anim_player: AnimationPlayer = $HandAnimationPlayer

signal item_equipped(item: Item, hand: String)
signal item_unequipped(item: Item, hand: String)
signal action_performed(action_type: String, item: Item, hand: String)

func _process(delta: float):
	if action_cooldown > 0:
		action_cooldown -= delta
		if action_cooldown <= 0:
			is_busy = false

func can_equip(item: Item) -> bool:
	if not item or equipped_item != null:
		return false
	
	# Check if it's a two-handed weapon and we need the dominant hand
	if item.is_two_handed and not is_dominant:
		return false
	
	return true

func has_item() -> bool:
	return equipped_item != null

func is_available() -> bool:
	return not is_busy and action_cooldown <= 0

func can_perform_action() -> bool:
	return has_item() and is_available()
	


func equip_item(item: Item) -> bool:
	if not can_equip(item):
		return false
	
	equipped_item = item
	update_visual()
	item_equipped.emit(item, hand_side)
	
	print("Equipped %s in %s hand" % [item.get_display_name(), hand_side])
	return true

func unequip_item() -> Item:
	var old_item = equipped_item
	if old_item:
		equipped_item = null
		clear_visual()
		item_unequipped.emit(old_item, hand_side)
		print("Unequipped %s from %s hand" % [old_item.get_display_name(), hand_side])
	return old_item

	

func perform_action(action_type: String = "primary") -> bool:
	if not can_perform_action():
		return false
	
	var success = false
	
	match action_type:
		"primary":
			success = perform_primary_action()
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
			# Set cooldown based on weapon speed
			action_cooldown = 1.0 / equipped_item.speed
			is_busy = true
			
			anim_player.play(equipped_item.attack_animations.pick_random())
			return true
		_:
			print("Unknown item category for action: ", equipped_item.category)
			return false

func update_visual():
	# Clear any existing visuals first
	clear_visual()
	
	if not equipped_item or not equipped_item.has_model():
		return
		
	# Handle PackedScene (.glb files)
	var scene_instance = equipped_item.model_scene.instantiate()
	if scene_instance:
		item_holder.add_child(scene_instance)
		current_model_instance = scene_instance
		print("Instantiated scene model: ", equipped_item.get_display_name())

func clear_visual():
	# Clear scene instance
	if current_model_instance:
		current_model_instance.queue_free()
		current_model_instance = null

func get_status_text() -> String:
	if not has_item():
		return "%s hand: Empty" % hand_side.capitalize()
	
	var status = "%s hand: %s" % [hand_side.capitalize(), equipped_item.get_display_name()]
	
	if is_busy:
		status += " (Busy)"
	elif action_cooldown > 0:
		status += " (Cooldown: %.1fs)" % action_cooldown
	
	return status