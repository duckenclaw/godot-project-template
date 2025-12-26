extends Area3D

@export var max_health = 100
@onready var current_health = max_health

func take_damage(damage: float, damage_type: String):
	current_health -= damage
	print("Dummy took " + str(damage) + damage_type + " damage")
	print("Dummy health: " + str(current_health) + "/" + str(max_health))