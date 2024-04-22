@tool
@icon("res://addons/Overmind/assets/camera_red.svg")
## Defines the parameters of a virtual camera to be used by a CameraBrain node.
class_name VirtualCamera3D extends Node3D

@export_group("General Settings")
## Whether the camera collides with objects or clips through them. CURRENTLY BUGGY
@export var collides: bool = false

@export_group("Location Settings")
## Which Node3D's position will be used to set the camera location.
@export var follow_node: Node3D:
	set(value):
		if typeof(value) in [CameraBrain3D, VirtualCamera3D]:
			push_warning("Do not set a camera's location as another camera.")
			return
		follow_node = value
## Dampening values for horizontal movement.
@export var horizontal_damper: DampedValue = DampedValue.new()
## Dampening values for vertical movement.
@export var vertical_damper: DampedValue = DampedValue.new()
## Orbiting values.
@export var orbiting: Orbiting3D = Orbiting3D.new()
@export_group("Rotation Settings")
## When enabled, the camera follows the rotation of the location node above,
## effectively staying behind it by default.
@export var follow_y_rotation: bool = false
## When enabled, the camera follows the location node's x and z axis rotation.
@export var follow_side_rotation: bool = false
## Dampening values for y axis rotation.
@export var y_rotation_damper: DampedValue = DampedValue.new()
## Dampening values for x and z axis rotation.
@export var side_rotation_damper: DampedValue = DampedValue.new()

# TODO
# CURRENT EXPORT RANGES FOR TILT/PAN/ETC ARE KINDA RANDOM
# TURN VALUES LIKE TILT/PAN INTO DEGREES

@export_group("Target Settings")
## Which Node3D's position(s) will be used to set the camera target.
## When set to a node, the camera will look at its target instead of its location node. 
## When disabled, all the location settings affect the target too, and the target settings do nothing;
## this is ideal for player cameras, or any camera that's meant to focus on the thing it orbits around.
@export var target_node: Node3D
## Dampening values for targeting.
@export var target_damper: DampedValue = DampedValue.new()

var target: Vector3
var location_rotation: Vector3 # Euler angles
var prev_rotation: Vector3
var turns: Vector3i = Vector3i(0, 0, 0)

func _ready():
	process_priority = 998
	
	if not follow_node:
		if Engine.is_editor_hint():
			horizontal_damper.start(Vector2(0, 0))
			vertical_damper.start(0)
			y_rotation_damper.start(0)
			side_rotation_damper.start(Vector2(0, 0))
		else:
			printerr("No follow node set.")
		return

	horizontal_damper.start(
		Vector2(follow_node.position.x, follow_node.position.z))
	vertical_damper.start(follow_node.position.y)
	y_rotation_damper.start(follow_node.rotation.y)
	side_rotation_damper.start(
		Vector2(follow_node.rotation.x, follow_node.rotation.z))
	
	position = follow_node.position
	prev_rotation = follow_node.rotation

	if not target_node:
		return

	target = target_node.position
	target_damper.start(target)

var new_location: Vector3
var new_target: Vector3

func _process(delta):
	# POSITION
	new_location = Vector3.ZERO if not follow_node else follow_node.position
	horizontal_damper.update(delta, Vector2(new_location.x, new_location.z))
	vertical_damper.update(delta, new_location.y)
	position = Vector3(
		horizontal_damper.value.x, 
		vertical_damper.value, 
		horizontal_damper.value.y
	)
	
	# ROTATION
	# Due to a Node3D's rotation going from -PI to PI, the number of turns needs
	# to be tracked here so the camera doesn't whiplash when rotating between PI and -PI
	# (i.e. when rotating between ~179º and ~181º)
	if follow_side_rotation and follow_node:
		if (follow_node.rotation - prev_rotation).z > 2:
			turns.z += 1
		if (follow_node.rotation - prev_rotation).z < -2:
			turns.z -= 1
		if (follow_node.rotation - prev_rotation).x > 2:
			turns.x += 1
		if (follow_node.rotation - prev_rotation).x < -2:
			turns.x -= 1
		
		side_rotation_damper.update(delta, 
			Vector2(follow_node.rotation.x, follow_node.rotation.z) + 
			Vector2(TAU * -turns.x, TAU * -turns.z))
		location_rotation.x = side_rotation_damper.value.x
		location_rotation.z = side_rotation_damper.value.z
		prev_rotation.x = follow_node.rotation.x
		prev_rotation.z = follow_node.rotation.z
		
	if follow_y_rotation and follow_node:
		if (follow_node.rotation - prev_rotation).y > 2:
			turns.y += 1
		if (follow_node.rotation - prev_rotation).y < -2:
			turns.y -= 1
		
		y_rotation_damper.update(delta, follow_node.rotation.y + TAU * -turns.y)
		location_rotation.y = y_rotation_damper.value
		prev_rotation.y = follow_node.rotation.y

	# TARGETING
	if target_node:
		new_target = target_node.position
		target_damper.update(delta, new_target)
		target = target_damper.value
	else:
		target = position
