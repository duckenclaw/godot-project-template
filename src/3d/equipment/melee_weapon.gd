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

func get_max_damage() -> float:
	return max(slash_damage, thrust_damage)

func get_average_damage() -> float:
	return (slash_damage + thrust_damage) / 2.0

func get_damage_text() -> String:
	if slash_damage > 0 and thrust_damage > 0:
		return "Slash: %.1f, Thrust: %.1f" % [slash_damage, thrust_damage]
	elif slash_damage > 0:
		return "Slash: %.1f" % slash_damage
	elif thrust_damage > 0:
		return "Thrust: %.1f" % thrust_damage
	else:
		return "No damage"

func get_speed_text() -> String:
	if speed >= 1.5:
		return "Very Fast (%.1fx)" % speed
	elif speed >= 1.2:
		return "Fast (%.1fx)" % speed
	elif speed >= 0.8:
		return "Normal (%.1fx)" % speed
	elif speed >= 0.6:
		return "Slow (%.1fx)" % speed
	else:
		return "Very Slow (%.1fx)" % speed

func get_info_text() -> String:
	var info = []
	info.append(super.get_info_text())
	info.append("Subcategory: " + subcategory)
	info.append("Damage: " + get_damage_text())
	info.append("Damage Type: " + damage_type)
	info.append("Range: " + weapon_range)
	info.append("Speed: " + get_speed_text())
	return "\n".join(info)

func can_slash() -> bool:
	return slash_damage > 0

func can_thrust() -> bool:
	return thrust_damage > 0
