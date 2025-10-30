extends Item
class_name MeleeWeapon

## Melee weapon class for close combat weapons
## Extends base Item with melee-specific properties

@export var subcategory: String = ""
@export var slash_damage: float = 0.0
@export var thrust_damage: float = 0.0
@export var damage_type: String = "kinetic"
@export var weapon_range: String = "short"  # Using weapon_range instead of range (reserved keyword)
@export var speed: float = 1.0

var attack_animations = ["slash_right", "slash_left", "thrust"]

func _init(
	p_name: String = "",
	p_icon: Texture2D = null,
	p_model_scene: PackedScene = null,
	p_model_mesh: Mesh = null,
	p_category: String = "melee",
	p_weight: float = 0.0,
	p_size: Vector2i = Vector2i(1, 1),
	p_is_two_handed: bool = false,
	p_description: String = "",
	p_subcategory: String = "",
	p_slash_damage: float = 0.0,
	p_thrust_damage: float = 0.0,
	p_damage_type: String = "physical",
	p_weapon_range: String = "short",
	p_speed: float = 1.0
):
	super(p_name, p_icon, p_model_scene, p_model_mesh, p_category, p_weight, p_size, p_is_two_handed, p_description)
	subcategory = p_subcategory
	slash_damage = p_slash_damage
	thrust_damage = p_thrust_damage
	damage_type = p_damage_type
	weapon_range = p_weapon_range
	speed = p_speed 

## Perform the primary action for this melee weapon
## Returns a dictionary with action results: {success: bool, cooldown: float}
func perform_primary_action(anim_player: AnimationPlayer, targets: Array) -> Dictionary:
	var result = {
		"success": false,
		"cooldown": 0.0
	}

	# Pick a random attack animation
	var animation = attack_animations.pick_random()

	# Calculate playback speed to make animation duration match the speed property
	var original_length = anim_player.get_animation(animation).length
	var playback_speed = original_length / speed

	# Play animation at calculated speed
	anim_player.play(animation, -1, playback_speed)
	print(animation)

	# Set cooldown to match animation duration
	result.cooldown = speed

	# Calculate damage based on animation type
	var damage: float
	match animation:
		"thrust":
			print("thrusting")
			damage = thrust_damage
		"slash_right", "slash_left":
			print("slashing")
			damage = slash_damage

	# Apply damage to all targets in range
	for target in targets:
		if target.has_method("take_damage"):
			target.take_damage(damage, damage_type)

	result.success = true
	return result
