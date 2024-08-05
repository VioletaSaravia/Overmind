@tool
@icon("res://addons/Overmind/assets/transition_red.svg")
class_name CameraTransition3D extends Path3D

@export var cam_1: VirtualCamera3D
@export var cam_2: VirtualCamera3D
# var path: PathFollow3D

@onready var cam: CameraBrain3D = $".."
#@onready var path: PathFollow3D = $PathFollow3D

func _ready():
	self.add_child(PathFollow3D.new())
	# self.path = get_child(0)

func _process(_delta):
	if not cam:
		print_debug("CameraTransition must be a child of a CameraBrain")
		
	if cam_1:
		curve.set_point_position(0, cam.calculate_camera(cam_1)[0])
	
	if cam_2:
		curve.set_point_position(2, cam.calculate_camera(cam_2)[0])
