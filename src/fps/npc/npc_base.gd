extends CharacterBody3D
class_name NPCBase

@export var max_health = 100
@onready var current_health = max_health

@export var dialog: DialogResource

func take_damage(damage: float, damage_type: String):
	current_health -= damage
	print("Dummy took " + str(damage) + damage_type + " damage")
	print("Dummy health: " + str(current_health) + "/" + str(max_health))

## Called by player interaction system to identify this as a character
func character():
	return self

## Returns the dialog resource for this NPC
func get_dialog() -> DialogResource:
	return dialog
	
