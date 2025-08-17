extends Control

# Node references
@onready var main_container: Control = $MainContainer
@onready var options_screen: Control = $OptionsScreen

# Reference to the player (will be set by player script)
var player: CharacterBody3D

func _ready():
	# Initially hide the pause menu
	visible = false
	# Set process mode to always so it works when paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	# Handle escape key when pause menu is visible
	if visible and event.is_action_pressed("ui_cancel"):
		_on_resume()
		get_viewport().set_input_as_handled()

func show_main_menu():
	if options_screen:
		options_screen.visible = false
	main_container.visible = true

func show_options():
	main_container.visible = false
	if options_screen:
		options_screen.visible = true

func _on_resume():
	if player:
		player.resume_game()

func _on_open_options():
	show_options()

func _on_close_options():
	show_main_menu()

func _on_exit_to_main_menu():
	# Unpause the game first
	get_tree().paused = false
	# Change to main menu scene
	get_tree().change_scene_to_file("res://src/ui/main_menu.tscn")

func _on_exit_to_desktop():
	get_tree().quit()