## Core node of Overmind for 3D scenes.
@tool
@icon("res://addons/Overmind/assets/brain_red.svg")
class_name CameraBrain3D extends Camera3D

@export_group("Virtual Cameras")
var vcams: Array[VirtualCamera3D]
@export var active_cam: int:
	set(value):
		if vcams.size() == 0:
			return
			
		active_cam = value % vcams.size()

var active: VirtualCamera3D: 
	get: return vcams[active_cam]

func _ready():
	process_priority = 999

	for cam in get_children():
		vcams.push_back(cam)

	position = active.position
	rotation = active.rotation

var col: Dictionary
@onready var space_state = get_world_3d().direct_space_state

func _process(delta):
	# CAMERA SCRIPTS
	if not Engine.is_editor_hint():
		for node in active.find_children("", "CameraScript3D"):
			node.execute(delta)
	
	# PLACEMENT
	var location: Vector3 = active.position
	var local_track = quaternion * Vector3(active.track, 0, 0)
	var local_pedestal = Vector3(0, active.pedestal, 0)
	
	var new_position: Vector3 = location + local_pedestal + local_track \
		+ calculate_orbit(active.dolly, active.yaw, active.pitch)
			
	if active.collides:
		var query = PhysicsRayQueryParameters3D.create(location, new_position, 1)
		query.collide_with_areas = true
		col = space_state.intersect_ray(query)
	
	position = col.position if col else new_position
	
	# TARGETING
	var track_focus = active.target + calculate_orbit(0, active.yaw + -PI/2, 0)
	look_at(track_focus + Vector3(active.pan, active.tilt, 0) + local_track)
	
	rotate(quaternion * Vector3.FORWARD, active.roll)

static func calculate_orbit(radius: float, yaw: float, pitch: float) -> Vector3:
	var ray := Vector3.FORWARD
	ray = Quaternion(Vector3.UP, TAU - yaw) * ray

	var pitchaxis := ray.cross(Vector3.UP)
	ray = Quaternion(pitchaxis, TAU - pitch) * ray

	return ray * - radius
