@tool
@icon("res://addons/Overmind/assets/camera_red.svg")
## Defines a virtual camera to be used by a CameraBrain node.
class_name VirtualCamera3D extends Node3D

@export_group("General")
## Freeze the camera in place.
@export var frozen: bool = false
## Whether the camera collides with objects or clips through them.
@export var collides: bool = false
## Represent the virtual camera as an eyeball in the viewport. Editor only.
@export var show_eyeball: bool = true

@export_group("Orbiting")
## Which Node3D's position the camera will orbit around.
@export var orbit: Node3D:
	set(value):
		if typeof(value) in [CameraBrain3D, VirtualCamera3D]:
			push_warning("Do not set a camera's orbit around another camera.")
			return
		orbit = value
## Damping values for horizontal movement.
@export var horizontal_damper := DampedValue.new()
## Damping values for vertical movement.
@export var vertical_damper := DampedValue.new()
## Damping values for axis rotation.
@export var rotation_damper := DampedValue.new()
## Offset from the orbit. Z moves back and forth, X and Y pan and elevate.
@export var distance := Vector3(0, 0, 3)
@export var distance_damper := DampedValue.new()
## Orbiting angle. Y moves around the sides, X up and down and Z rolls the camera.
@export var angle: Vector3 = Vector3(0.4, 0, 0)
@export var angle_damper := DampedValue.new()
## When enabled, the camera follows the rotation of the orbit node,
## effectively staying behind it by default. Great for racing games, but 
## you'll want manual rotation controls for most other games.
@export var follow_rotation: bool = false

@export_group("Look At")
## Which node the camera will look at. Leave empty to look at the orbit node.
@export var look_at_node: Node3D
## Damping values for targeting.
@export var look_damper := DampedValue.new()
## Pan and tilt the camera.
@export var look_offset: Vector2 = Vector2(0, 0)

@export_group("Manual Input")
@export var actions := CameraControls.new()
@export var manual_move_damper := DampedValue.new()
@export var manual_rotation_damper := DampedValue.new()
@export var move_speed := Vector3(3, 3, 3)
@export var rotation_speed := Vector3(3, 3, 3)


static var model_asset = preload("res://addons/Overmind/assets/eye.obj")
@onready var model := MeshInstance3D.new()

var targeting: Vector3
var rotating: float

var orbit_position: Vector3
var orbit_target: Vector3
var orbit_rotation: float

func _ready():
	top_level = true
	process_priority = 998
	
	if Engine.is_editor_hint():
		add_child(model)
		self.model.mesh = model_asset
		self.model.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	distance_damper.start(distance)
	angle_damper.start(angle)
	
	manual_move_damper.start(Vector3.ZERO)
	manual_rotation_damper.start(Vector3.ZERO)
	
	calculate_orbit_position()
	calculate_orbit_rotation()
	calculate_orbit_target()
	
	#prev_rotation = orbit.rotation
	look_damper.start(
		(look_at_node.position if look_at_node else 
			(orbit.position if orbit else Vector3.ZERO))
		+ orbit_target
		+ Vector3(distance_damper.value.x, distance_damper.value.y, 0)
	)
	
	if not orbit:
		if Engine.is_editor_hint():
			horizontal_damper.start(Vector2(0, 0))
			vertical_damper.start(0)
			rotation_damper.start(Vector3(0, 0, 0))
		else:
			printerr("No orbit node set.")
		return
	
	horizontal_damper.start(Vector2(
		orbit_position.x + orbit.position.x + distance_damper.value.x, 
		orbit_position.z + orbit.position.z
	))
	vertical_damper.start(orbit_position.y + orbit.position.y + distance_damper.value.y)
	rotation_damper.start(orbit.rotation)


# Due to a Node3D's rotation going from -PI to PI, the number of turns needs to
# be tracked here so the camera doesn't whiplash when rotating between PI and
# -PI (i.e. when rotating between ~179º and ~181º)
var new_rotation: Vector3 # Euler angles
var prev_rotation: Vector3
var turns: Vector3i = Vector3i(0, 0, 0)

func _process(delta):
	if self.model: self.model.visible = show_eyeball
	if frozen: return
	
	angle_damper.update(delta, angle)
	distance_damper.update(delta, distance)
	
	calculate_manual_input(delta)
	
	calculate_orbit_position()
	calculate_orbit_target()
	
	# POSITION
	var pos := (Vector3.ZERO if not orbit else orbit.position)
	horizontal_damper.update(delta, Vector2(pos.x, pos.z))
	vertical_damper.update(delta, pos.y)
	position = Vector3(
		horizontal_damper.value.x,
		vertical_damper.value,
		horizontal_damper.value.y) \
		+ orbit_position \
		+ Vector3(distance_damper.value.x, distance_damper.value.y, 0) \
		+ manual_move_damper.value
	
	# ROTATION
	if follow_rotation and orbit:
		if (orbit.rotation - prev_rotation).z > 2: turns.z += 1
		if (orbit.rotation - prev_rotation).z < -2: turns.z -= 1
		if (orbit.rotation - prev_rotation).x > 2: turns.x += 1
		if (orbit.rotation - prev_rotation).x < -2: turns.x -= 1
		if (orbit.rotation - prev_rotation).y > 2: turns.y += 1
		if (orbit.rotation - prev_rotation).y < -2: turns.y -= 1
	
		rotation_damper.update(delta, orbit.rotation + TAU * -turns)
		prev_rotation.x = orbit.rotation.x
		prev_rotation.z = orbit.rotation.z
		new_rotation = rotation_damper.value
		prev_rotation = orbit.rotation
	
	calculate_orbit_rotation()
	rotate(quaternion * Vector3.FORWARD, orbit_rotation)
	
	# TARGETING
	if orbit:
		look_damper.update(
			delta,
			(look_at_node.position if look_at_node else orbit.position)
			+ orbit_target
			+ Vector3(distance_damper.value.x, distance_damper.value.y, 0)
		)
	if not position.is_equal_approx(look_damper.value):
		look_at(look_damper.value)
	
	# Pass values to CameraBrain3D
	targeting = look_damper.value
	rotating = orbit_rotation

func calculate_manual_input(delta: float) -> void:
	var new_move := Vector3.ZERO
	
	if actions.x_movement_neg != "" and Input.is_action_pressed(actions.x_movement_neg):
		new_move.x -= move_speed.x * delta
	if actions.x_movement_pos != "" and Input.is_action_pressed(actions.x_movement_pos):
		new_move.x += move_speed.x * delta
	if actions.y_movement_neg != "" and Input.is_action_pressed(actions.y_movement_neg):
		new_move.y -= move_speed.y * delta
	if actions.y_movement_pos != "" and Input.is_action_pressed(actions.y_movement_pos):
		new_move.y += move_speed.y * delta
	if actions.z_movement_neg != "" and Input.is_action_pressed(actions.z_movement_neg):
		new_move.z -= move_speed.z * delta
	if actions.z_movement_pos != "" and Input.is_action_pressed(actions.z_movement_pos):
		new_move.z += move_speed.z * delta
		
	manual_move_damper.update(delta, manual_move_damper.value + new_move)
	
	var new_rotation := Vector3.ZERO
	
	if actions.x_rotation_neg != "" and Input.is_action_pressed(actions.x_rotation_neg):
		new_rotation.x -= rotation_speed.x * delta
	if actions.x_rotation_pos != "" and Input.is_action_pressed(actions.x_rotation_pos):
		new_rotation.x += rotation_speed.x * delta
	if actions.y_rotation_neg != "" and Input.is_action_pressed(actions.y_rotation_neg):
		new_rotation.y -= rotation_speed.y * delta
	if actions.y_rotation_pos != "" and Input.is_action_pressed(actions.y_rotation_pos):
		new_rotation.y += rotation_speed.y * delta
	if actions.z_rotation_neg != "" and Input.is_action_pressed(actions.z_rotation_neg):
		new_rotation.z -= rotation_speed.z * delta
	if actions.z_rotation_pos != "" and Input.is_action_pressed(actions.z_rotation_pos):
		new_rotation.z += rotation_speed.z * delta
		
	manual_rotation_damper.update(delta, manual_rotation_damper.value + new_rotation)

static func calculate_orbit(radius: float, yaw: float, pitch: float) -> Vector3:
	var ray := Vector3.FORWARD
	ray = Quaternion(Vector3.UP, TAU - yaw) * ray
	
	var pitchaxis := ray.cross(Vector3.UP)
	ray = Quaternion(pitchaxis, TAU - pitch) * ray
	
	return ray * -radius

func calculate_orbit_position() -> void:
	orbit_position = calculate_orbit(
		distance_damper.value.z,
		manual_rotation_damper.value.y + angle_damper.value.y - new_rotation.y,
		manual_rotation_damper.value.x + angle_damper.value.x - new_rotation.x
	)

func calculate_orbit_target() -> void:
	orbit_target = calculate_orbit(0, 
		manual_rotation_damper.value.y + angle_damper.value.y + -PI / 2, 0) \
		+ Vector3(look_offset.x, look_offset.y, 0)

func calculate_orbit_rotation() -> void:
	orbit_rotation = manual_rotation_damper.value.z \
		+ angle_damper.value.z \
		- new_rotation.z
