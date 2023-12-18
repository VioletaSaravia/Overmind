## Core node of Overmind for 2D scenes.
@icon("res://addons/Overmind/assets/brain_blue.svg")
class_name CameraBrain2D extends Camera2D

@export_group("Virtual Cameras")
var vcams: Array[VirtualCamera2D]
@export var active_cam: int: 
	set(value): active_cam = value % vcams.size()

var active: VirtualCamera2D:
	get: return vcams[active_cam]

func _ready():
	process_priority = 999

	for cam in get_children():
		vcams.push_back(cam)
		
	position = active.location

func _process(delta):
	for node in active.find_children("", "CameraScript"):
		node.execute(delta)
	
	position = active.location + active.offset + polar_to_xy(active.radius, active.angle)

static func polar_to_xy(radius: float, angle: float) -> Vector2:
	return Vector2(radius * cos(angle), radius * sin(angle))
