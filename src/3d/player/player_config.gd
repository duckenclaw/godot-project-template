extends Resource
class_name PlayerConfig

## Player configuration with stat system and calculated properties
## Stats: might, fortitude, motorics
## Calculated properties: weight, speed, jump_height, dash_length, sprint_multiplier

@export var might: float = 10.0
@export var fortitude: float = 10.0  
@export var motorics: float = 10.0
@export var willpower: float = 10.0
@export var starting_weight: float = 70.0

# Calculated properties
var weight: float:
	get:
		return starting_weight + ((fortitude * 10) + (might * 5))

var speed: float:
	get:
		return (motorics * 5) / (weight / 10 - might)

var jump_height: float:
	get:
		return might * 1.5

var dash_length: float:
	get:
		return motorics / 20

var sprint_multiplier: float:
	get:
		return 1 + (motorics * 0.25)

var max_health: float:
	get:
		return 35 + (5 * fortitude)

var max_mana: float:
	get:
		return 25 + (5 * willpower)

func _init(p_might: float = 10.0, p_fortitude: float = 10.0, p_motorics: float = 10.0, p_starting_weight: float = 70.0):
	might = p_might
	fortitude = p_fortitude
	motorics = p_motorics
	starting_weight = p_starting_weight

func get_stats_summary() -> String:
	return "Stats - Might: %.1f, Fortitude: %.1f, Motorics: %.1f\nCalculated - Weight: %.1f, Speed: %.1f, Jump: %.1f, Dash: %.1f, Sprint: %.2fx" % [
		might, fortitude, motorics, weight, speed, jump_height, dash_length, sprint_multiplier
	]
