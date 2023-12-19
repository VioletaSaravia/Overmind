@tool
@icon("res://addons/Overmind/assets/camera_red.svg")
## Defines the parameters of a virtual camera to be used by a CameraBrain node.
class_name VirtualCamera3D extends Node3D

@export_group("General Settings")
## Set the target to be the same as the location. When enabled, all the location
## settings affect the target too, and the target settings do nothing.
## Ideal for player cameras.
@export var target_equals_location: bool = true
## Whether the camera collides with objects or clips through them.
@export var collides: bool = true

@export_group("Location Settings")
## Which Node3D's position will be used to set the camera location.
@export var follow_node: Node3D
@export var follow_horizontal: bool = true
@export var follow_vertical: bool = true
@export var horizontal_damper: DampedValue = DampedValue.new()
@export var vertical_damper: DampedValue = DampedValue.new()
@export var orbiting: Orbiting3D = Orbiting3D.new()

# TODO
# CURRENT EXPORT RANGES FOR TILT/PAN/ETC ARE KINDA RANDOM
# TURN VALUES LIKE TILT/PAN INTO DEGREES

@export_group("Target Settings")
## Which Node3D's position(s) will be used to set the camera target.
@export var target_node: Node3D
@export var target_damper: DampedValue = DampedValue.new()
var target: Vector3

func _ready():
	process_priority = 998
	
	if not follow_node:
		if Engine.is_editor_hint():
			horizontal_damper.start(Vector2(0, 0))
			vertical_damper.start(0)
		else:
			printerr("No follow node set.")
		return

	horizontal_damper.start(
		Vector2(follow_node.position.x, follow_node.position.z))
	vertical_damper.start(follow_node.position.y)
	
	position = follow_node.position

	if not target_node:
		return

	target = target_node.position
	target_damper.start(target)

var new_location: Vector3
var new_target: Vector3

func _process(delta):
	new_location = Vector3.ZERO \
		if not follow_node \
		else follow_node.position
		
	horizontal_damper.update(delta, Vector2(new_location.x, new_location.z))
	vertical_damper.update(delta, new_location.y)
	
	position = Vector3(
		horizontal_damper.value.x, 
		vertical_damper.value, 
		horizontal_damper.value.y
	)
		
	if not target_node:
		target = position
		return

	new_target = target_node.position
	target_damper.update(delta, new_target)
	target = target_damper.value
