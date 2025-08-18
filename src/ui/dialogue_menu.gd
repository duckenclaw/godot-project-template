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
		next_dialog = dialog.nodes.filter(func(n): return n.id == current_dialog.choices[0].next)[0]
		advance(next_dialog)
	elif event.is_action_pressed("equip_2") and waiting_for_choice:
		next_dialog = dialog.nodes.filter(func(n): return n.id == current_dialog.choices[1].next)[0]
		advance(next_dialog)
	elif event.is_action_pressed("equip_3") and waiting_for_choice:
		next_dialog = dialog.nodes.filter(func(n): return n.id == current_dialog.choices[2].next)[0]
		advance(next_dialog)
	elif event.is_action_pressed("equip_4") and waiting_for_choice:
		next_dialog = dialog.nodes.filter(func(n): return n.id == current_dialog.choices[3].next)[0]
		advance(next_dialog)


func advance(dialog_node: DialogNode):
	# speaker turn
	waiting_for_choice = false
	choice_button_container.visible = false
	current_dialog = dialog_node
	dialog_text.text = dialog_node.text
	#	speaker_icon.texture = speaker_texture
	
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
		next_dialog = dialog.nodes.filter(func(n): return n.id == current_dialog.next)[0]
		advance(next_dialog)
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


func _on_dialog_choice_1():
	next_dialog = dialog.nodes.filter(func(n): return n.id == current_dialog.choices[0].next)[0]
	advance(next_dialog)


func _on_dialog_choice_2():
	next_dialog = dialog.nodes.filter(func(n): return n.id == current_dialog.choices[1].next)[0]
	advance(next_dialog)


func _on_dialog_choice_3():
	next_dialog = dialog.nodes.filter(func(n): return n.id == current_dialog.choices[2].next)[0]
	advance(next_dialog)


func _on_dialog_choice_4():
	next_dialog = dialog.nodes.filter(func(n): return n.id == current_dialog.choices[3].next)[0]
	advance(next_dialog)
