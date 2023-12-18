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
@export var follow_nodes: Array[Node3D]
@export var follow_horizontal: bool = true
@export var follow_vertical: bool = true
@export var horizontal_damper: DampedValue = DampedValue.new()
var x_damper: DampedValue = DampedValue.new()
var z_damper: DampedValue = DampedValue.new()
@export var vertical_damper: DampedValue = DampedValue.new()

# TODO
# CURRENT EXPORT RANGES FOR TILT/PAN/ETC ARE KINDA RANDOM
# TURN VALUES LIKE TILT/PAN INTO DEGREES

@export_subgroup("Orbiting Settings")
## Distance from location.
@export_range(0, 20) var dolly: float = 3
## Vertical rotation.
@export_range(-3, 3) var tilt: float = 1
## Horizontal rotation
@export_range(-3, 3) var pan: float = 0
## Horizontal displacement.
@export_range(-3, 3) var track: float = 0
## Vertical displacement.
@export_range(-1, 30) var pedestal: float = 1
## Horizontal pivoting around location.
@export_range(-TAU, TAU) var yaw: float
## Vertical pivoting around location.
@export_range(-TAU/4 + 0.1, TAU/4 - 0.1) var pitch: float = .3
## Rotation of the camera along its longitudinal axis.
@export_range(- TAU / 2, TAU / 2) var roll: float = 0

@export_group("Target Settings")
## Which Node3D's position(s) will be used to set the camera target.
@export var target_nodes: Array[Node3D]
@export var target_damper: DampedValue
var target: Vector3

@onready var cam: Camera3D = $".."

func _ready():
	process_priority = 998
	
	if follow_nodes.size() == 0 or follow_nodes[0] == null:
		if Engine.is_editor_hint():
			pass
			x_damper.start(0)
			z_damper.start(0)
			vertical_damper.start(0)
		else:
			printerr("Location Follow Node array contains no nodes.")
		return
		
	x_damper = horizontal_damper.duplicate()
	x_damper.start(follow_nodes[0].position.x)
	z_damper = horizontal_damper.duplicate()
	z_damper.start(follow_nodes[0].position.z)
	vertical_damper.start(follow_nodes[0].position.y)
	
	position = follow_nodes[0].position

	if target_equals_location:
		return

	if target_nodes.size() == 0: 
		printerr("Target Follow Node array contains no nodes.")
		return
		
	target = target_nodes[0].position
	target_damper.start(target)

func _process(delta):
	# TODO ugh
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
	
	var new_location: Vector3
	if follow_nodes.size() == 0 or follow_nodes[0] != null:
		new_location = Vector3.ZERO
	else:
		new_location = follow_nodes[0].position
		
	for n in follow_nodes:
		if n != null:
			new_location = lerp(new_location, n.position, 0.5)
	
	x_damper.update(delta, new_location.x)
	z_damper.update(delta, new_location.z)
	vertical_damper.update(delta, new_location.y)
	
	position = Vector3(x_damper.value, vertical_damper.value, z_damper.value)
		
	if target_equals_location:
		target = position
		return

	var new_target: Vector3 = target_nodes[0].position \
		if target_nodes[0] != null \
		else Vector3.ZERO

	for n in target_nodes:
		if n != null:
			new_target = lerp(new_target, n.position, 0.5)

	target_damper.update(delta, new_target)
	target = target_damper.value
