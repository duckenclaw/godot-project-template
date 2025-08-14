extends Node
class_name StateMachine

## Finite State Machine for managing player states
## Handles state transitions and delegates calls to active state

@export var initial_state: NodePath
var current_state: State
var states: Dictionary = {}

@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")

func _ready():
	# Wait for all children to be ready
	await get_tree().process_frame
	
	# Initialize all states
	for child in get_children():
		if child is State:
			states[child.get_state_name()] = child
			child.state_transition_requested.connect(_on_state_transition_requested)
	
	# Start with initial state
	if initial_state and not initial_state.is_empty():
		var initial_state_node = get_node(initial_state)
		if initial_state_node and initial_state_node is State:
			current_state = initial_state_node
			current_state.enter()
	elif states.size() > 0:
		# Default to first state if no initial state set
		current_state = states.values()[0]
		current_state.enter()

func _process(delta: float):
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float):
	if current_state:
		current_state.physics_update(delta)

func _input(event: InputEvent):
	if current_state:
		current_state.handle_input(event)

func transition_to(new_state_name: String) -> void:
	if not states.has(new_state_name):
		print("Warning: State '%s' does not exist!" % new_state_name)
		return
	
	if current_state:
		current_state.exit()
	
	current_state = states[new_state_name]
	current_state.enter()
	
	print("State transition: -> %s" % new_state_name)

func _on_state_transition_requested(new_state_name: String) -> void:
	transition_to(new_state_name)

func get_current_state_name() -> String:
	if current_state:
		return current_state.get_state_name()
	return "none"
