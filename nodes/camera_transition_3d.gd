@tool
@icon("res://addons/Overmind/assets/transition_red.svg")
class_name CameraTransition3D extends Path3D

@export var cam_1: VirtualCamera3D
@export var cam_2: VirtualCamera3D

@onready var cam: CameraBrain3D = $".."
var path_follow: PathFollow3D

@export_range(0.0, 1.0) var path_position := 0.0:
	set(value):
		path_position = value
		if path_follow: path_follow.progress_ratio = value
			
var progress: float: 
	get: return path_follow.progress_ratio if path_follow else 0

func _ready():
	top_level = true
	self.add_child(PathFollow3D.new())
	self.path_follow = get_child(0)
	
	curve.add_point(Vector3.ZERO)
	curve.add_point(Vector3.ZERO)
	curve.add_point(Vector3.ZERO)

func _process(_delta):
	if not cam:
		print_debug("CameraTransition must be a child of a CameraBrain")
		
	if cam_1: curve.set_point_position(0, cam_1.position)
	if cam_2: curve.set_point_position(2, cam_2.position)
	if cam_1 and cam_2: curve.set_point_position(1, lerp(cam_1.position, cam_2.position, 0.5))
