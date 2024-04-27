@tool
extends Node
@onready var cam: VirtualCamera3D

# TODO Test
func _process(delta):
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
		cam.horizontal_damper.set_parameters(1, 2, 3)
		
	if Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down"):
		cam.horizontal_damper.set_parameters(1, 1, 0)
