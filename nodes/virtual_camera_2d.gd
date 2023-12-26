@tool
@icon("res://addons/Overmind/assets/camera_blue.svg")
## Defines the parameters of a virtual camera to be used by a CameraBrain node.
class_name VirtualCamera2D extends Node2D

@export_group("Location Settings")
## Which Node2D's position will be used to set the camera location.
@export var follow_node: Node2D
@export var follow_x: bool = true
@export var follow_y: bool = true
@export var x_damper: DampedValue = DampedValue.new()
@export var y_damper: DampedValue = DampedValue.new()
@export var orbiting: Orbiting2D = Orbiting2D.new()

@onready var cam: Camera2D = $".."

func _ready():
	process_priority = 998
	
	if not follow_node:
		if Engine.is_editor_hint():
			x_damper.start(0)
			y_damper.start(0)
		else:
			printerr("No Follow Node selected.")
		return
		
	x_damper.start(follow_node.position.x)
	y_damper.start(follow_node.position.y)
	
	position = follow_node.position

func _process(delta):
	if not follow_node:
		return

	var new_location: Vector2 = Vector2(
		follow_node.position.x if follow_x else position.x, 
		follow_node.position.y if follow_y else position.y
	)
		
	x_damper.update(delta, new_location.x)
	y_damper.update(delta, new_location.y)
	
	position = Vector2(x_damper.value, y_damper.value)
