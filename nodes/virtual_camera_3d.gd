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
## Which Node3D's position(s) will be used to set the camera location.
@export var follow_node: Node3D
@export var follow_horizontal: bool = true
@export var follow_vertical: bool = true
@export var horizontal_damper: DampedValue = DampedValue.new()
var x_damper: DampedValue = DampedValue.new()
var z_damper: DampedValue = DampedValue.new()
@export var vertical_damper: DampedValue = DampedValue.new()
@export var orbiting: Orbiting = Orbiting.new()

# TODO
# CURRENT EXPORT RANGES FOR TILT/PAN/ETC ARE KINDA RANDOM
# TURN VALUES LIKE TILT/PAN INTO DEGREES

@export_group("Target Settings")
## Which Node3D's position(s) will be used to set the camera target.
@export var target_node: Node3D
@export var target_damper: DampedValue = DampedValue.new()
var target: Vector3

@onready var cam: Camera3D = $".."

func _ready():
	process_priority = 998
	print(follow_node)
	
	if not follow_node:
		if Engine.is_editor_hint():
			pass
			x_damper.start(0)
			z_damper.start(0)
			vertical_damper.start(0)
		else:
			printerr("Location Follow Node array contains no nodes.")
		return
		
	x_damper = horizontal_damper.duplicate()
	x_damper.start(follow_node.position.x)
	z_damper = horizontal_damper.duplicate()
	z_damper.start(follow_node.position.z)
	vertical_damper.start(follow_node.position.y)
	
	position = follow_node.position

	if target_equals_location:
		return

	if target_node.size() == 0: 
		printerr("Target Follow Node array contains no nodes.")
		return
		
	target = target_node.position
	target_damper.start(target)
	

func _process(delta):
	# TODO ugh. pasar a setter de horizontal?
	x_damper.set_parameters(
		horizontal_damper.f,
		horizontal_damper.z,
		horizontal_damper.r
	)
	z_damper.set_parameters(
		horizontal_damper.f,
		horizontal_damper.z,
		horizontal_damper.r
	)
	
	var new_location: Vector3 = Vector3.ZERO \
		if not follow_node \
		else follow_node.position
		
	x_damper.update(delta, new_location.x)
	z_damper.update(delta, new_location.z)
	vertical_damper.update(delta, new_location.y)
	
	position = Vector3(x_damper.value, vertical_damper.value, z_damper.value)
		
	if target_equals_location:
		target = position
		return

	var new_target: Vector3 = Vector3.ZERO \
		if target_node == null \
		else target_node.position

	target_damper.update(delta, new_target)
	target = target_damper.value
