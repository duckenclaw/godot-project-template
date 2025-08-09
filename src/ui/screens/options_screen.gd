extends Control

@onready var screen_mode_options := $MarginContainer/OptionsContainer/Graphics/MarginContainer/FlowContainer/ScreenMode/OptionButton
@onready var resolution_options := $MarginContainer/OptionsContainer/Graphics/MarginContainer/FlowContainer/Resolution/OptionButton

signal close_options()

func _on_close_options_pressed():
	close_options.emit()

func _on_screen_mode_item_selected(index):
	match screen_mode_options.get_item_text(index).to_lower():
		"windowed": 
			print("windowed selected")
			#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		"fullscreen": 
			print("fullscreen selected")
			#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_resolution_item_selected(index):
	var resolution = resolution_options.get_item_text(index).split("x")
	var width = resolution[0]
	var height = resolution[1]
	print("width: " + width)
	print("width: " + height)
