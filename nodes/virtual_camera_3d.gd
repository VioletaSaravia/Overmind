@tool
@icon("res://addons/Overmind/assets/camera_red.svg")
## Defines the parameters of a virtual camera to be used by a CameraBrain node.
class_name VirtualCamera3D extends Node3D

@export_group("General Settings")
## Set the target to be the same as the location. When enabled, all the location
## settings affect the target too, and the target settings do nothing.
## Ideal for player cameras, or any camera that's meant to focus on the thing it
## orbits around.
@export var target_equals_location: bool = true
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
## When enabled, the camera follows the rotation of the node above, effectively
## staying behind it by default.
@export var follow_node_rotation: bool = false
# TODO constraints
## Dampening values for horizontal movement.
@export var horizontal_damper: DampedValue = DampedValue.new()
## Dampening values for vertical movement.
@export var vertical_damper: DampedValue = DampedValue.new()
## Dampening values for rotation.
@export var rotation_damper: DampedValue = DampedValue.new()
## Orbiting values.
@export var orbiting: Orbiting3D = Orbiting3D.new()

# TODO
# CURRENT EXPORT RANGES FOR TILT/PAN/ETC ARE KINDA RANDOM
# TURN VALUES LIKE TILT/PAN INTO DEGREES

@export_group("Target Settings")
## Which Node3D's position(s) will be used to set the camera target.
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
			rotation_damper.start(Vector3(0,0,0))
		else:
			printerr("No follow node set.")
		return

	horizontal_damper.start(
		Vector2(follow_node.position.x, follow_node.position.z))
	vertical_damper.start(follow_node.position.y)
	rotation_damper.start(follow_node.rotation)
	
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
	if follow_node_rotation:
		# Due to a Node3D's rotation going from -PI to PI, the number of turns needs
		# to be tracked here so the camera doesn't whiplash when going from PI to -PI
		# (i.e. when rotation - prev_rotation is a large number)
		if (follow_node.rotation - prev_rotation).y > 2:
			turns.y += 1
		if (follow_node.rotation - prev_rotation).y < -2:
			turns.y -= 1
		if (follow_node.rotation - prev_rotation).x > 2:
			turns.x += 1
		if (follow_node.rotation - prev_rotation).x < -2:
			turns.x -= 1
		if (follow_node.rotation - prev_rotation).z > 2:
			turns.z += 1
		if (follow_node.rotation - prev_rotation).z < -2:
			turns.z -= 1
		
		rotation_damper.update(delta, follow_node.rotation + 
			Vector3(TAU * -turns.x, TAU * -turns.y, TAU * -turns.z))
		location_rotation = rotation_damper.value
		prev_rotation = follow_node.rotation

	# TARGETING
	if not target_node:
		target = position
		return
		
	# Added to .update()
	# TODO test
	#if not target_damper.started:
		#target_damper.start(target_node.position)
		
	new_target = target_node.position
	target_damper.update(delta, new_target)
	target = target_damper.value
