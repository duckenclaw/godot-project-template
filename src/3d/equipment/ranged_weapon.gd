extends Item
class_name RangedWeapon

## Ranged weapon class for projectile weapons
## Extends base Item with ranged-specific properties

@export var damage: float = 0.0
@export var damage_type: String = "physical"
@export var accuracy: float = 1.0  # 1.0 = perfect accuracy, lower = less accurate
@export var rpm: float = 60.0  # Rounds per minute
@export var magazine_size: int = 10
@export var reload_time: float = 2.0

# Runtime state (not exported)
var current_ammo: int = 0
var is_reloading: bool = false

func _init(
	p_name: String = "",
	p_icon: Texture2D = null,
	p_model_scene: PackedScene = null,
	p_model_mesh: Mesh = null,
	p_category: String = "ranged",
	p_weight: float = 0.0,
	p_size: Vector2i = Vector2i(1, 1),
	p_is_two_handed: bool = true,
	p_description: String = "",
	p_damage: float = 0.0,
	p_damage_type: String = "physical",
	p_accuracy: float = 1.0,
	p_rpm: float = 60.0,
	p_magazine_size: int = 10,
	p_reload_time: float = 2.0
):
	super(p_name, p_icon, p_model_scene, p_model_mesh, p_category, p_weight, p_size, p_is_two_handed, p_description)
	damage = p_damage
	damage_type = p_damage_type
	accuracy = p_accuracy
	rpm = p_rpm
	magazine_size = p_magazine_size
	reload_time = p_reload_time
	current_ammo = magazine_size  # Start fully loaded

func get_fire_rate() -> float:
	return rpm / 60.0  # Shots per second

func get_time_between_shots() -> float:
	return 60.0 / rpm  # Seconds between shots

func get_accuracy_text() -> String:
	var accuracy_percent = accuracy * 100.0
	if accuracy_percent >= 95:
		return "Excellent (%.0f%%)" % accuracy_percent
	elif accuracy_percent >= 80:
		return "Good (%.0f%%)" % accuracy_percent
	elif accuracy_percent >= 60:
		return "Fair (%.0f%%)" % accuracy_percent
	else:
		return "Poor (%.0f%%)" % accuracy_percent

func get_fire_rate_text() -> String:
	return "%.0f RPM (%.1f/sec)" % [rpm, get_fire_rate()]

func get_ammo_text() -> String:
	return "%d/%d" % [current_ammo, magazine_size]

func get_info_text() -> String:
	var info = []
	info.append(super.get_info_text())
	info.append("Damage: %.1f %s" % [damage, damage_type])
	info.append("Accuracy: " + get_accuracy_text())
	info.append("Fire Rate: " + get_fire_rate_text())
	info.append("Magazine: %d rounds" % magazine_size)
	info.append("Reload Time: %.1fs" % reload_time)
	info.append("Current Ammo: " + get_ammo_text())
	return "\n".join(info)

func can_fire() -> bool:
	return current_ammo > 0 and not is_reloading

func needs_reload() -> bool:
	return current_ammo == 0

func is_magazine_full() -> bool:
	return current_ammo >= magazine_size

func fire() -> bool:
	if can_fire():
		current_ammo -= 1
		return true
	return false

func start_reload():
	if not is_magazine_full():
		is_reloading = true

func finish_reload():
	current_ammo = magazine_size
	is_reloading = false

func add_ammo(amount: int) -> int:
	var old_ammo = current_ammo
	current_ammo = min(current_ammo + amount, magazine_size)
	return current_ammo - old_ammo  # Return amount actually added
