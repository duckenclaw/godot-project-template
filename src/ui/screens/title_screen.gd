extends Control

signal continue_game(type: String)
signal open_options()
signal exit_game()


func _on_start_button_pressed():
	continue_game.emit("2D")

func _on_start_3d_button_pressed():
	continue_game.emit("3D")

func _on_options_button_pressed():
	open_options.emit()


func _on_exit_button_pressed():
	exit_game.emit()
