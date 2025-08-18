extends Resource
class_name DialogNode

@export var id: String = ""
@export var speaker_icon: Texture2D
@export var speaker: String = ""   # e.g. "npc1"
@export var text: String = ""
@export var choices: Array[DialogChoice] = []
@export var set_flags: Array[String] = []
@export var conditions: Array[String] = []   # flags required to unlock this node
@export var next: String = ""                # if no choices, auto-advance
