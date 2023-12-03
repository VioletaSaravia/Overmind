## Core node of Overmind for 3D scenes.
@icon("res://addons/Overmind/assets/brain_red.svg")
class_name CameraBrain3D extends Camera3D

@export_group("Virtual Cameras")
var vcams: Array[VirtualCamera3D]
@export var active_cam: int: 
	set(value):
		active_cam = value % vcams.size()
		location_node = vcams[active_cam].get_child(0)
		target_node = vcams[active_cam].get_child(1)

var active: VirtualCamera3D: 
	get:
		return vcams[active_cam]

var location_node: Node3D
var target_node: Node3D

func _ready():
	process_priority = 999

	for cam in get_children():
		vcams.push_back(cam)

	location_node = vcams[active_cam].get_child(0)
	target_node = vcams[active_cam].get_child(1)
	self.position = location_node.position
	self.rotation = location_node.rotation

var col: Dictionary
@onready var space_state = get_world_3d().direct_space_state

func _physics_process(delta):
	# CAMERA SCRIPTS
	for node in active.find_children("", "CameraScript"):
		node.execute(delta)
	
	# PLACEMENT
	var location: Vector3 = location_node.position
	var local_track = quaternion * Vector3(active.track, 0, 0)
	var local_pedestal = Vector3(0, active.pedestal, 0)
	
	var new_position: Vector3 = location + local_pedestal + local_track \
		+ get_orbit(active.radius, active.yaw, active.pitch)
			
	if active.collides:
		var origin = location_node.position
		var end = new_position
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		query.collide_with_areas = true
		col = space_state.intersect_ray(query)
	
	self.position = col.get("position") if col else new_position
	
	# TARGETING
	var target: Vector3 = target_node.position
	var track_focus = target + get_orbit(0, active.yaw + -PI/2, 0)
	self.look_at(track_focus + Vector3(0, active.tilt, 0) + local_track)

func get_orbit(_radius: float, _yaw: float, _pitch: float) -> Vector3:
	var ray := Vector3.FORWARD
	ray = Quaternion(Vector3.UP, TAU - _yaw) * ray

	var _pitch_axis := ray.cross(Vector3.UP)
	ray = Quaternion(_pitch_axis, TAU - _pitch) * ray

	return ray * - _radius
