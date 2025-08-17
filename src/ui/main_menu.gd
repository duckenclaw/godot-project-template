extends Control

@onready var start_scene_2d: PackedScene = preload("res://src/2d/game/test_2D.tscn")
@onready var start_scene_3d: PackedScene = preload("res://src/3d/test_3D.tscn")

@onready var title_screen: Control = $TitleScreen
@onready var options_screen: Control = $OptionsScreen

func _change_screen(screen: Control):
	# Disable all screens before turning on the target screen
	title_screen.visible = false
	options_screen.visible = false
	
	screen.visible = true

func _on_continue_game(type: String):
	var start_scene
	if type == "2D":
		start_scene = start_scene_2d
	elif type == "3D":
		start_scene = start_scene_3d
	get_tree().change_scene_to_packed(start_scene)

func _on_open_options():
	_change_screen(options_screen)

func _on_exit_game():
	get_tree().quit(0)

func _on_close_options():
	_change_screen(title_screen)
