@tool
@icon("res://addons/Overmind/assets/transition_blue.svg")
class_name CameraTransition2D extends Path2D

@export var cam_1: VirtualCamera2D
@export var cam_2: VirtualCamera2D
var path: PathFollow2D

@onready var cam: CameraBrain2D = $".."
@onready var player_cam = $"../PlayerCamera"
@onready var object_cam = $"../ObjectCamera"
#@onready var path: PathFollow3D = $PathFollow3D

func _ready():
	self.add_child(PathFollow2D.new())
	self.path = get_child(0)

func _process(_delta):
	curve.set_point_position(0, cam.calculate_camera(cam_1)[0])
	curve.set_point_position(2, cam.calculate_camera(cam_2)[0])
