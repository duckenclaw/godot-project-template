extends Item
class_name MagicItem

## Magic item class for casting spells
## Extends base Item with magic-specific properties

@export var subcategory: String = ""
@export var mana_cost: float = 10.0
@export var spell_damage: float = 0.0
@export var damage_type: String = "fire"
@export var spell_range: float = 10.0
@export var cast_speed: float = 1.0

# Combo to spell mapping
var combo_spells = {
	"": "ignite",                    # Neutral - Ignite
	"forward": "flame_spray",         # Forward - Flame Spray
	"backward": "wall_of_fire",       # Backward - Wall of Fire
	"circularMotion": "fire_nova",    # Circle motion - Fire Nova
	"forward-backward": "blaze_trail" # Back and forth - Blaze Trail
}

func _init(
	p_name: String = "",
	p_icon: Texture2D = null,
	p_model_scene: PackedScene = null,
	p_model_mesh: Mesh = null,
	p_category: String = "magic",
	p_weight: float = 0.0,
	p_size: Vector2i = Vector2i(1, 1),
	p_is_two_handed: bool = false,
	p_description: String = "",
	p_subcategory: String = "",
	p_mana_cost: float = 10.0,
	p_spell_damage: float = 0.0,
	p_damage_type: String = "fire",
	p_spell_range: float = 10.0,
	p_cast_speed: float = 1.0
):
	super(p_name, p_icon, p_model_scene, p_model_mesh, p_category, p_weight, p_size, p_is_two_handed, p_description)
	subcategory = p_subcategory
	mana_cost = p_mana_cost
	spell_damage = p_spell_damage
	damage_type = p_damage_type
	spell_range = p_spell_range
	cast_speed = p_cast_speed

## Perform the primary action for this magic item
## Returns a dictionary with action results: {success: bool, cooldown: float}
## combo_input: String representing the detected combo (e.g., "forward-backward", "circularMotion")
func perform_primary_action(anim_player: AnimationPlayer, targets: Array, combo_input: String = "") -> Dictionary:
	var result = {
		"success": false,
		"cooldown": 0.0
	}

	# Safety check: ensure anim_player is valid
	if not is_instance_valid(anim_player):
		push_warning("MagicItem: AnimationPlayer is invalid or freed")
		return result

	# Get spell based on combo input
	var spell: String
	if combo_input in combo_spells:
		spell = combo_spells[combo_input]
	else:
		spell = combo_spells[""]  # Use default (ignite)

	print("Combo: ", combo_input, " -> Spell: ", spell)

	# Execute the spell effect
	match spell:
		"ignite":
			cast_ignite(targets)
		"flame_spray":
			cast_flame_spray(targets)
		"wall_of_fire":
			cast_wall_of_fire(targets)
		"fire_nova":
			cast_fire_nova(targets)
		"blaze_trail":
			cast_blaze_trail(targets)

	# Set cooldown based on cast speed
	result.cooldown = cast_speed
	result.success = true
	return result

## Ignite - Ignites a target you're currently looking at
func cast_ignite(targets: Array):
	print("Casting Ignite")
	# TODO: Implement raycast to find target player is looking at
	# For now, just damage the first target
	if targets.size() > 0:
		var target = targets[0]
		if is_instance_valid(target) and target.has_method("take_damage"):
			target.take_damage(spell_damage, damage_type)
			print("Ignited target for ", spell_damage, " ", damage_type, " damage")

## Flame Spray - Start spraying flames directly in front of you
func cast_flame_spray(targets: Array):
	print("Casting Flame Spray")
	# Damage all targets in front in a cone
	for target in targets:
		if is_instance_valid(target) and target.has_method("take_damage"):
			target.take_damage(spell_damage * 0.8, damage_type)
			print("Flame sprayed target for ", spell_damage * 0.8, " ", damage_type, " damage")

## Wall of Fire - Summon multiple columns of fire in a line in front of you
func cast_wall_of_fire(targets: Array):
	print("Casting Wall of Fire")
	# TODO: Spawn fire columns in a line
	# For now, damage targets with area damage
	for target in targets:
		if is_instance_valid(target) and target.has_method("take_damage"):
			target.take_damage(spell_damage * 1.2, damage_type)
			print("Wall of fire damaged target for ", spell_damage * 1.2, " ", damage_type, " damage")

## Fire Nova - Explodes and ignites an area around you
func cast_fire_nova(targets: Array):
	print("Casting Fire Nova")
	# Area damage around player
	for target in targets:
		if is_instance_valid(target) and target.has_method("take_damage"):
			target.take_damage(spell_damage * 1.5, damage_type)
			print("Fire nova damaged target for ", spell_damage * 1.5, " ", damage_type, " damage")

## Blaze Trail - Dash forward leaving a trail of flames behind you
func cast_blaze_trail(targets: Array):
	print("Casting Blaze Trail")
	# TODO: Trigger player dash and spawn fire trail
	# For now, damage targets
	for target in targets:
		if is_instance_valid(target) and target.has_method("take_damage"):
			target.take_damage(spell_damage, damage_type)
			print("Blaze trail damaged target for ", spell_damage, " ", damage_type, " damage")
