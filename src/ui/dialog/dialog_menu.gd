extends Control

@onready var player_icon: TextureRect = $PlayerIcon

var player_texture

@onready var speaker_icon: TextureRect = $SpeakerIcon

var speaker_texture

# Reference to the player node
var player: CharacterBody3D

@onready var dialog_text: RichTextLabel = $DialogPanel/MarginContainer/VBoxContainer/DialogText 
@onready var choice_button_container: VBoxContainer = $DialogChoices

@export var choice_buttons: Array[Button]

@onready var choice_button_1: Button = $DialogChoices/DialogChoiceButton1
@onready var choice_button_2: Button = $DialogChoices/DialogChoiceButton2
@onready var choice_button_3: Button = $DialogChoices/DialogChoiceButton3
@onready var choice_button_4: Button = $DialogChoices/DialogChoiceButton4

@export var dialog: DialogResource

@onready var current_dialog: DialogNode = dialog.nodes[0]

var next_dialog: DialogNode
var dialog_choices: Array[DialogChoice]
var waiting_for_input: bool  = true
var waiting_for_choice: bool = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("activate"):
		print(waiting_for_input)
		advance(current_dialog)
	elif event.is_action_pressed("equip_1") and waiting_for_choice:
		next_dialog = find_next_valid_dialog_node(current_dialog.choices[0].next)
		if next_dialog:
			advance(next_dialog)
		else:
			exit_dialog()
	elif event.is_action_pressed("equip_2") and waiting_for_choice:
		next_dialog = find_next_valid_dialog_node(current_dialog.choices[1].next)
		if next_dialog:
			advance(next_dialog)
		else:
			exit_dialog()
	elif event.is_action_pressed("equip_3") and waiting_for_choice:
		next_dialog = find_next_valid_dialog_node(current_dialog.choices[2].next)
		if next_dialog:
			advance(next_dialog)
		else:
			exit_dialog()
	elif event.is_action_pressed("equip_4") and waiting_for_choice:
		next_dialog = find_next_valid_dialog_node(current_dialog.choices[3].next)
		if next_dialog:
			advance(next_dialog)
		else:
			exit_dialog()


func advance(dialog_node: DialogNode):
	# speaker turn
	waiting_for_choice = false
	choice_button_container.visible = false
	current_dialog = dialog_node
	dialog_text.text = dialog_node.text
	#	speaker_icon.texture = speaker_texture
	
	# Process set_flags for this dialog node
	process_flags(dialog_node.set_flags)
	
	print("Current Dialog Node: " + current_dialog.id + "\nChoices: " + str(current_dialog.choices.size()) + "\nNext: " + current_dialog.next)

	if current_dialog.choices.size() > 0 and not waiting_for_input:
		print("dialogue node has choices, waiting for input to advance to player turn")
		waiting_for_input = true
	elif current_dialog.choices.size() > 0 and waiting_for_input:
		print("advancing to player turn")
		waiting_for_input = false
		player_turn(dialog_node.choices)
	elif current_dialog.choices.size() == 0 and not waiting_for_input:
		("no choices,")
		waiting_for_input = true
	elif current_dialog.next == "end" and waiting_for_input:
		print("ending dialogue")
		exit_dialog()
		return
	elif waiting_for_input:
		print("advancing to next default dialogue node")
		waiting_for_input = false
		next_dialog = find_next_valid_dialog_node(current_dialog.next)
		if next_dialog:
			advance(next_dialog)
		else:
			print("No valid dialog node found, ending dialogue")
			exit_dialog()
		return


func player_turn(choices: Array[DialogChoice]):
	choice_button_container.visible = true
	#	player_icon.texture = player_texture
	waiting_for_choice = true
	
	choice_button_1.visible = false
	choice_button_2.visible = false
	choice_button_3.visible = false
	choice_button_4.visible = false
	
	var choice_button_index = 0
	for choice in choices:
		match choice_button_index: 
			0:
				choice_button_1.text = choice.text
				choice_button_1.visible = true
			1:
				choice_button_2.text = choice.text
				choice_button_2.visible = true
			2:
				choice_button_3.text = choice.text
				choice_button_3.visible = true
			3:
				choice_button_4.text = choice.text
				choice_button_4.visible = true
		choice_button_index += 1




func start_dialog():
	choice_button_container.visible = false
	print("dialogue started")
	print("advancing to " + current_dialog.id)
	advance(current_dialog)
	waiting_for_input = true


func exit_dialog():
	print("dialogue exited")
	if player:
		player.end_dialogue()

# Helper functions for story flag system
func process_flags(flags: Array[String]) -> void:
	if not player or not player.player_config:
		return
	
	for flag in flags:
		player.player_config.add_flag(flag)

func check_conditions(conditions: Array[String]) -> bool:
	if not player or not player.player_config:
		return true  # If no player config, allow all nodes
	
	if conditions.is_empty():
		return true  # No conditions means always accessible
	
	return player.player_config.has_all_flags(conditions)

func find_next_valid_dialog_node(node_id: String) -> DialogNode:
	var current_node_id = node_id
	
	# Keep searching until we find a valid node or reach the end
	while current_node_id != "end" and current_node_id != "":
		var candidate_node = dialog.nodes.filter(func(n): return n.id == current_node_id)
		
		if candidate_node.is_empty():
			print("Dialog node not found: " + current_node_id)
			return null
		
		var node = candidate_node[0] as DialogNode
		
		# Check if this node's conditions are met
		if check_conditions(node.conditions):
			print("Found valid dialog node: " + node.id)
			return node
		else:
			print("Skipping dialog node " + node.id + " due to unmet conditions: " + str(node.conditions))
			# Skip to the next node
			current_node_id = node.next
	
	# If we reach here, no valid node was found
	return null


func _on_dialog_choice_1():
	next_dialog = find_next_valid_dialog_node(current_dialog.choices[0].next)
	if next_dialog:
		advance(next_dialog)
	else:
		exit_dialog()


func _on_dialog_choice_2():
	next_dialog = find_next_valid_dialog_node(current_dialog.choices[1].next)
	if next_dialog:
		advance(next_dialog)
	else:
		exit_dialog()


func _on_dialog_choice_3():
	next_dialog = find_next_valid_dialog_node(current_dialog.choices[2].next)
	if next_dialog:
		advance(next_dialog)
	else:
		exit_dialog()


func _on_dialog_choice_4():
	next_dialog = find_next_valid_dialog_node(current_dialog.choices[3].next)
	if next_dialog:
		advance(next_dialog)
	else:
		exit_dialog()
