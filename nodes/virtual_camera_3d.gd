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
## Offset from the orbit. Z moves back and forth, X and Y pan and elevate.
@export var distance := Vector3(0, 0, 3)
## Orbiting angle. Y moves around the sides, X up and down and Z rolls the camera.
@export var angle: Vector3 = Vector3(0.4, 0, 0)
## When enabled, the camera follows the rotation of the orbit node,
## effectively staying behind it by default. Great for racing games, but 
## you'll want manual rotation controls for most other games.
@export var follow_rotation: bool = false

@export_group("Look At")
## Which node the camera will look at. Leave empty to look at the orbit node.
@export var look_at_node: Node3D
## Pan and tilt the camera.
@export var look_offset: Vector2 = Vector2(0, 0)

@export_group("Dampers")
## Damping values for horizontal movement.
@export var horizontal_damper: DampedValue = DampedValue.new()
## Damping values for vertical movement.
@export var vertical_damper: DampedValue = DampedValue.new()
## Damping values for axis rotation.
@export var rotation_damper: DampedValue = DampedValue.new()
## Damping values for targeting.
@export var look_damper: DampedValue = DampedValue.new()

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
			rotation_damper.start(Vector3(0, 0, 0))
		else:
			printerr("No orbit node set.")
		return
		
	calculate_orbit_position()
	calculate_orbit_rotation()
	calculate_orbit_target()
	
	horizontal_damper.start(Vector2(
		orbit_position.x + orbit.position.x + distance.x, 
		orbit_position.z + orbit.position.z
	))
	vertical_damper.start(orbit_position.y + orbit.position.y + distance.y)
	rotation_damper.start(orbit.rotation)
	
	#prev_rotation = orbit.rotation
	look_damper.start(
		(look_at_node.position if look_at_node else orbit.position)
		+ orbit_target
		+ Vector3(distance.x, distance.y, 0)
	)

# Due to a Node3D's rotation going from -PI to PI, the number of turns needs to
# be tracked here so the camera doesn't whiplash when rotating between PI and
# -PI (i.e. when rotating between ~179º and ~181º)
var new_rotation: Vector3 # Euler angles
var prev_rotation: Vector3
var turns: Vector3i = Vector3i(0, 0, 0)

func _process(delta):
	if self.model: self.model.visible = show_eyeball
	if frozen: return
	
	calculate_orbit_position()
	calculate_orbit_target()
	
	# POSITION
	var pos := (Vector3.ZERO if not orbit else orbit.position) \
		+ orbit_position \
		+ Vector3(distance.x, distance.y, 0)
	horizontal_damper.update(delta, Vector2(pos.x, pos.z))
	vertical_damper.update(delta, pos.y)
	position = Vector3(
		horizontal_damper.value.x,
		vertical_damper.value,
		horizontal_damper.value.y
	)
	
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
	look_damper.update(
		delta,
		(look_at_node.position if look_at_node else orbit.position)
		+ orbit_target
		+ Vector3(distance.x, distance.y, 0)
	)
	if position != look_damper.value: # Prevents error on first frame
		look_at(look_damper.value)
	
	# Pass values to CameraBrain3D
	targeting = look_damper.value
	rotating = orbit_rotation

static func calculate_orbit(radius: float, yaw: float, pitch: float) -> Vector3:
	var ray := Vector3.FORWARD
	ray = Quaternion(Vector3.UP, TAU - yaw) * ray
	
	var pitchaxis := ray.cross(Vector3.UP)
	ray = Quaternion(pitchaxis, TAU - pitch) * ray
	
	return ray * -radius

var targeting: Vector3
var rotating: float

var orbit_position: Vector3
var orbit_target: Vector3
var orbit_rotation: float

func calculate_orbit_position() -> void:
	orbit_position = calculate_orbit(
		distance.z,
		angle.y - new_rotation.y,
		angle.x - new_rotation.x
	)

func calculate_orbit_target() -> void:
	orbit_target = calculate_orbit(0, angle.y + -PI / 2, 0) \
		+ Vector3(look_offset.x, look_offset.y, 0)

func calculate_orbit_rotation() -> void:
	orbit_rotation = angle.z - new_rotation.z
