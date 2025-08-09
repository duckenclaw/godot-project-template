extends Control

signal close_options()

func _on_close_options_pressed():
	close_options.emit()
