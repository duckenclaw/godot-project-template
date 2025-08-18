extends Node
class_name Character

@export_group("Character Information")
@export var dialogue_icon: Texture2D
@export var dialogue: Array[String]

func use(player):
	startDialogue()
	
func startDialogue():
	pass
