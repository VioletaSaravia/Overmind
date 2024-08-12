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
	top_level = true
	process_priority = 999
	
	for cam in get_children():
		if cam is VirtualCamera3D:
			vcams.push_back(cam)

	update_configuration_warnings()
	if vcams.size() == 0:
		return

	position = active.position
	rotation = active.rotation

func _get_configuration_warnings() -> PackedStringArray:
	var result: Array[String] = []
	if vcams.size() == 0:
		result.append("CameraBrain must have at least one VirtualCamera3D as a child to work.")
	
	return result

func _process(delta):
	vcams.clear()
	for cam in get_children():
		if cam is VirtualCamera3D:
			vcams.push_back(cam)

	update_configuration_warnings()
	if vcams.size() == 0:
		return

	if not transitioning:
		position = active.position
		look_at(active.targeting)
		rotate(quaternion * Vector3.FORWARD, active.rotating)
		
		return
		
	# TODO Transitions
	## Instant transition
	#if trans_length == 0:
		#var new_cam = calculate_camera(trans_to)
		#position = new_cam[0]
		#look_at(new_cam[1])
		#rotate(quaternion * Vector3.FORWARD, new_cam[2])
#
		#transitioning = false
		#set_cam(trans_to) # TODO OOPS. THINK HOW TO CHANGE THIS
		#return
#
	## Timed lerp transition
	#if transition_type == TransitionType.LERP:
		#var cam_from: Array = calculate_camera(active)
		#var cam_to: Array = calculate_camera(trans_to)
#
		#position = lerp(cam_from[0], cam_to[0], cur_length / trans_length)
		#look_at(lerp(cam_from[1], cam_to[1], cur_length / trans_length))
		#rotate(quaternion * Vector3.FORWARD,
			#lerp(cam_from[2], cam_to[2], cur_length / trans_length))
#
	## Timed path transition
	#if transition_type == TransitionType.PATH:
		#var cam_from: Array = calculate_camera(active)
		#var cam_to: Array = calculate_camera(trans_to)
		#trans_path.progress_ratio += delta / trans_length
#
		#position = trans_path.position
		#look_at(lerp(cam_from[1], cam_to[1], cur_length / trans_length))
		#rotate(quaternion * Vector3.FORWARD,
			#lerp(cam_from[2], cam_to[2], cur_length / trans_length))
#
	#cur_length += delta
	#if cur_length > trans_length:
		#transitioning = false
		#set_cam(trans_to) # TODO OOPS. THINK HOW TO CHANGE THIS
		#cur_length = 0

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
