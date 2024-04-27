## Core node of Overmind for 3D scenes.
@tool
@icon("res://addons/Overmind/assets/brain_red.svg")
class_name CameraBrain3D extends Camera3D

@export_group("Virtual Cameras")
var vcams: Array[VirtualCamera3D]:
	set(value):
		vcams = value
		update_configuration_warnings()

@export var active_cam: int:
	set(value):
		if vcams.size() == 0:
			return
		active_cam = value % vcams.size()

var active: VirtualCamera3D: 
	get: return vcams[active_cam]

func set_cam(name: VirtualCamera3D):
	var maybe_active_cam = vcams.find(name)
	if maybe_active_cam != -1:
		active_cam = maybe_active_cam

func _ready():
	process_priority = 999
	for cam in get_children():
		if cam is VirtualCamera3D:
			vcams.push_back(cam)
	
	update_configuration_warnings()
	if vcams.size() == 0:
		return
	
	position = active.position
	rotation = active.rotation

var col: Dictionary
@onready var space_state = get_world_3d().direct_space_state

func _get_configuration_warnings() -> PackedStringArray:
	if vcams.size() == 0:
		return ["CameraBrain must have at least one VirtualCamera3D as a child to work."]
	else:
		return []

func _process(delta):
	# TODO this sucks
	vcams.clear()
	for cam in get_children():
		if cam is VirtualCamera3D:
			vcams.push_back(cam)
	
	update_configuration_warnings()
	if vcams.size() == 0:
		return
	
	if not transitioning:
		var new_cam = calculate_camera(active)
		position = new_cam[0]
		look_at(new_cam[1])
		rotate(quaternion * Vector3.FORWARD, new_cam[2])
		return
	
	# Instant transition
	if trans_length == 0:
		var new_cam = calculate_camera(trans_to)
		position = new_cam[0]
		look_at(new_cam[1])
		rotate(quaternion * Vector3.FORWARD, new_cam[2])
		
		transitioning = false
		set_cam(trans_to) # TODO OOPS. THINK HOW TO CHANGE THIS
		return
	
	# Timed lerp transition
	if transition_type == TransitionType.LERP:
		var cam_from: Array = calculate_camera(active)
		var cam_to: Array = calculate_camera(trans_to)
		
		position = lerp(cam_from[0], cam_to[0], cur_length / trans_length)
		look_at(lerp(cam_from[1], cam_to[1], cur_length / trans_length))
		rotate(quaternion * Vector3.FORWARD,
			lerp(cam_from[2], cam_to[2], cur_length / trans_length))
	
	# Timed path transition
	if transition_type == TransitionType.PATH:
		var cam_from: Array = calculate_camera(active)
		var cam_to: Array = calculate_camera(trans_to)
		trans_path.progress_ratio += delta / trans_length
		
		position = trans_path.position
		look_at(lerp(cam_from[1], cam_to[1], cur_length / trans_length))
		rotate(quaternion * Vector3.FORWARD,
			lerp(cam_from[2], cam_to[2], cur_length / trans_length))
	
	cur_length += delta
	if cur_length > trans_length:
		transitioning = false
		set_cam(trans_to) # TODO OOPS. THINK HOW TO CHANGE THIS
		cur_length = 0

static func calculate_orbit(radius: float, yaw: float, pitch: float) -> Vector3:
	var ray := Vector3.FORWARD
	ray = Quaternion(Vector3.UP, TAU - yaw) * ray
	
	var pitchaxis := ray.cross(Vector3.UP)
	ray = Quaternion(pitchaxis, TAU - pitch) * ray
	
	return ray * - radius

func calculate_camera(cam: VirtualCamera3D) -> Array: # (Vector3, Vector3, float)
	# PLACEMENT
	var local_track = quaternion * Vector3(cam.orbiting.track, 0, 0)
	var local_pedestal = Vector3(0, cam.orbiting.pedestal, 0)
	var local_yaw = cam.orbiting.yaw - cam.location_rotation.y
	var local_pitch = cam.orbiting.pitch - cam.location_rotation.x
	var new_position: Vector3 = cam.position + local_pedestal + local_track \
		+ calculate_orbit(cam.orbiting.dolly, local_yaw, local_pitch)
	
	# FIXME COLLISION CHECKING
	if cam.collides:
		var query = PhysicsRayQueryParameters3D.create(cam.position, new_position, 1)
		query.collide_with_areas = true
		col = space_state.intersect_ray(query)
	
	var pos = col.position if col else new_position
	
	# TARGETING
	var track_focus = cam.target + calculate_orbit(0, cam.orbiting.yaw + -PI/2, 0)
	var tar = track_focus + Vector3(cam.orbiting.pan, cam.orbiting.tilt, 0) + local_track
	
	# ROTATION
	var rot = cam.orbiting.roll - cam.location_rotation.z
	
	return [pos, tar, rot]

enum TransitionType {PATH, LERP}
var transition_type: TransitionType = TransitionType.LERP
var transitioning: bool = false
var trans_to: VirtualCamera3D
var trans_length: float = 0
var cur_length: float = 0
func transition(to: VirtualCamera3D, duration: float = 0):
	trans_to = to
	transitioning = true
	trans_length = duration
	transition_type = TransitionType.LERP

var trans_path: PathFollow3D
enum PathDirection {FORWARD, BACKWARD} # TODO USE THIS
func path_transition(to: VirtualCamera3D, path: Path3D, duration: float = 2):
	# TODO HOW TO HANDLE POSITIVE VS NEGATIVE SEMANTICS??
	trans_to = to
	transitioning = true
	trans_length = duration
	transition_type = TransitionType.PATH
	trans_path = path.get_child(0)

func next_cam(duration: float = 0):
	transition(vcams[active_cam + 1 if active_cam + 1 != vcams.size() else 0], duration)
