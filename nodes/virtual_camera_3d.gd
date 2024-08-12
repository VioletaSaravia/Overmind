@tool
@icon("res://addons/Overmind/assets/camera_red.svg")
## Defines a virtual camera to be used by a CameraBrain node.
class_name VirtualCamera3D extends Node3D

@export_group("General")
## Freeze the camera in place.
@export var frozen: bool = false
## Whether the camera collides with objects or clips through them. CURRENTLY BUGGY
@export var collides: bool = false
## Represent the virtual camera as an eyeball in the viewport. Editor only.
@export var show_eyeball: bool = true

@export_group("Dampers")
## Damping values for horizontal movement.
@export var horizontal_damper: DampedValue = DampedValue.new()
## Damping values for vertical movement.
@export var vertical_damper: DampedValue = DampedValue.new()
## Damping values for y axis rotation.
@export var y_rotation_damper: DampedValue = DampedValue.new()
## Damping values for x and z axis rotation.
@export var side_rotation_damper: DampedValue = DampedValue.new()
## Damping values for targeting. Only used if "Look at Node" is set.
@export var look_damper: DampedValue = DampedValue.new()

@export_group("Manual Controls")
## Actions to use for manual movement.
@export var actions: CameraControls = CameraControls.new()
## Movement speed when utilizing actions.
@export var actions_movement_speed: Vector3 = Vector3(1, 1, 1)
## Rotation speed when utilizing actions.
@export var actions_rotation_speed: Vector3 = Vector3(1, 1, 1)

@export_group("Orbiting")
## Which Node3D's position the camera will orbit around.
@export var orbit: Node3D:
	set(value):
		if typeof(value) in [CameraBrain3D, VirtualCamera3D]:
			push_warning("Do not set a camera's orbit around another camera.")
			return
		orbit = value
## Offset from the orbit. Z moves back and forth, X and Y pan and elevate.
@export var distance: Vector3 = Vector3(0, 0, 2)
## Orbiting angle. Y moves around the sides, X up and down and Z rolls the camera.
@export var angle: Vector3 = Vector3(0, 2, 0)
## When enabled, the camera follows the rotation of the orbit node,
## effectively staying behind it by default.
@export var follow_y_rotation: bool = false
## When enabled, the camera follows the orbit node's x and z axis rotation.
@export var follow_side_rotation: bool = false

@export_group("Look At")
## Which node the camera will look at. Leave empty to look at the orbit node.
@export var look_at_node: Node3D
## Pan and tilt the camera.
@export var look_offset: Vector2 = Vector2(0, 0)


static var model_asset = preload("res://addons/Overmind/assets/eye.obj")
@onready var model: MeshInstance3D = MeshInstance3D.new()

func _ready():
	top_level = true
	process_priority = 998
	
	if Engine.is_editor_hint():
		add_child(model)
		self.model.mesh = model_asset
		self.model.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		
	if not orbit:
		if Engine.is_editor_hint():
			horizontal_damper.start(Vector2(0, 0))
			vertical_damper.start(0)
			y_rotation_damper.start(0)
			side_rotation_damper.start(Vector2(0, 0))
		else:
			printerr("No follow node set.")
		return

	horizontal_damper.start(
		Vector2(orbit.position.x, orbit.position.z))
	vertical_damper.start(orbit.position.y)
	y_rotation_damper.start(orbit.rotation.y)
	side_rotation_damper.start(
		Vector2(orbit.rotation.x, orbit.rotation.z))

	position = orbit.position
	prev_rotation = orbit.rotation

	if not look_at_node:
		return

	target = look_at_node.position
	look_damper.start(target)

var new_location: Vector3
var new_target: Vector3

var target: Vector3
var orbit_rotation: Vector3 # Euler angles
var prev_rotation: Vector3
var turns: Vector3i = Vector3i(0, 0, 0)

func _process(delta):
	if self.model:
		self.model.visible = show_eyeball
		
	if frozen:
		return
		
	# TODO All of this goes *after* calculate camera!!!
	# i.e. orbit and manual offsets should be damped too!!!
	
	# POSITION
	new_location = Vector3.ZERO if not orbit else orbit.position
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
	if follow_side_rotation and orbit:
		if (orbit.rotation - prev_rotation).z > 2:
			turns.z += 1
		if (orbit.rotation - prev_rotation).z < -2:
			turns.z -= 1
		if (orbit.rotation - prev_rotation).x > 2:
			turns.x += 1
		if (orbit.rotation - prev_rotation).x < -2:
			turns.x -= 1

		side_rotation_damper.update(delta,
			Vector2(orbit.rotation.x, orbit.rotation.z) +
			Vector2(TAU * -turns.x, TAU * -turns.z))
		orbit_rotation.x = side_rotation_damper.value.x
		orbit_rotation.z = side_rotation_damper.value.y
		prev_rotation.x = orbit.rotation.x
		prev_rotation.z = orbit.rotation.z

	if follow_y_rotation and orbit:
		if (orbit.rotation - prev_rotation).y > 2:
			turns.y += 1
		if (orbit.rotation - prev_rotation).y < -2:
			turns.y -= 1

		y_rotation_damper.update(delta, orbit.rotation.y + TAU * -turns.y)
		orbit_rotation.y = y_rotation_damper.value
		prev_rotation.y = orbit.rotation.y

	# TARGETING
	if look_at_node:
		new_target = look_at_node.position
		look_damper.update(delta, new_target)
		target = look_damper.value
	else:
		target = position
		
	calculate_camera(delta)
	
static func calculate_orbit(radius: float, yaw: float, pitch: float) -> Vector3:
	var ray := Vector3.FORWARD
	ray = Quaternion(Vector3.UP, TAU - yaw) * ray

	var pitchaxis := ray.cross(Vector3.UP)
	ray = Quaternion(pitchaxis, TAU - pitch) * ray

	return ray * -radius

# Collision-related variables
var col: Dictionary
@onready var space_state = get_world_3d().direct_space_state

# Needed to use look_at and rotate on CameraBrain, I think?
var targeting: Vector3
var rotating: float

var manual_move := Vector3(0, 0, 0)
var manual_rot := Vector3(0, 0, 0)
	
func calculate_camera(delta: float):
	# MANUAL MOVEMENT
	if actions.x_movement_neg != &"" and Input.is_action_pressed(actions.x_movement_neg):
		manual_move.x -= actions_movement_speed.x * delta
	if actions.x_movement_pos != &"" and Input.is_action_pressed(actions.x_movement_pos):
		manual_move.x += actions_movement_speed.x * delta
	if actions.y_movement_neg != &"" and Input.is_action_pressed(actions.y_movement_neg):
		manual_move.y -= actions_movement_speed.y * delta
	if actions.y_movement_pos != &"" and Input.is_action_pressed(actions.y_movement_pos):
		manual_move.y += actions_movement_speed.y * delta
	if actions.z_movement_neg != &"" and Input.is_action_pressed(actions.z_movement_neg):
		manual_move.z -= actions_movement_speed.z * delta
	if actions.z_movement_pos != &"" and Input.is_action_pressed(actions.z_movement_pos):
		manual_move.z += actions_movement_speed.z * delta
		
	if actions.x_rotation_neg != &"" and Input.is_action_pressed(actions.x_rotation_neg):
		manual_rot.x -= actions_rotation_speed.x * delta
	if actions.x_rotation_pos != &"" and Input.is_action_pressed(actions.x_rotation_pos):
		manual_rot.x += actions_rotation_speed.x * delta
	if actions.y_rotation_neg != &"" and Input.is_action_pressed(actions.y_rotation_neg):
		manual_rot.y -= actions_rotation_speed.y * delta
	if actions.y_rotation_pos != &"" and Input.is_action_pressed(actions.y_rotation_pos):
		manual_rot.y += actions_rotation_speed.y * delta
	if actions.z_rotation_neg != &"" and Input.is_action_pressed(actions.z_rotation_neg):
		manual_rot.z -= actions_rotation_speed.z * delta
	if actions.z_rotation_pos != &"" and Input.is_action_pressed(actions.z_rotation_pos):
		manual_rot.z += actions_rotation_speed.z * delta
		
	manual_move = quaternion * manual_move

	# PLACEMENT
	# TODO Recalculate all this
	var local_track = quaternion * Vector3(distance.x, 0, 0)
	var local_pedestal = Vector3(0, distance.y, 0)
	var local_yaw = angle.y - orbit_rotation.y - manual_rot.y
	var local_pitch = angle.x - orbit_rotation.x - manual_rot.x
	var new_position: Vector3 = position + manual_move + local_pedestal + local_track \
		+ calculate_orbit(distance.z, local_yaw, local_pitch)
	
	# FIXME COLLISION CHECKING
	if collides:
		var query = PhysicsRayQueryParameters3D.create(position, new_position, 1)
		query.collide_with_areas = true
		col = space_state.intersect_ray(query)

	var pos = col.position if col else new_position

	# TARGETING
	var track_focus = target + calculate_orbit(0, angle.y + -PI / 2, 0)
	var tar = track_focus + Vector3(look_offset.x, look_offset.y, 0) + local_track

	# ROTATION
	var rot = angle.z - orbit_rotation.z - manual_rot.z

	position = pos
	targeting = tar
	look_at(tar)
	rotating = rot
	rotate(quaternion * Vector3.FORWARD, rot)
