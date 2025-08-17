extends AnimatableBody3D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@export var is_open: bool = false
@export var is_locked: bool = false
@export var key: Item


func use():
	if !is_open:
		anim_player.play("open")
		is_open = true
	else:
		anim_player.play("close")
		is_open = false