extends Node
class_name State

## Base state class for the player state machine
## All player states should extend this class

signal state_transition_requested(new_state_name: String)

@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var state_machine: StateMachine = get_parent()

## Called when the state is entered
func enter() -> void:
	pass

## Called when the state is exited
func exit() -> void:
	pass

## Called every frame while the state is active
func update(delta: float) -> void:
	pass

## Called every physics frame while the state is active
func physics_update(delta: float) -> void:
	pass

## Called when input events occur while the state is active
func handle_input(event: InputEvent) -> void:
	pass

## Helper function to request a state transition
func transition_to(new_state_name: String) -> void:
	state_transition_requested.emit(new_state_name)

## Get the state name (override in child classes)
func get_state_name() -> String:
	return name.to_lower()
