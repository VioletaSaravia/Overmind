## Core node of Overmind for 2D scenes.
@tool
@icon("res://addons/Overmind/assets/brain_blue.svg")
class_name CameraBrain2D extends Camera2D

@export_group("Virtual Cameras")
var vcams: Array[VirtualCamera2D]:
	set(value):
		vcams = value
		update_configuration_warnings()

@export var active_cam: int:
	set(value):
		if vcams.size() == 0:
			return
			
		active_cam = value % vcams.size()

var active: VirtualCamera2D: 
	get: return vcams[active_cam]

func _ready():
	process_priority = 999
	for cam in get_children():
		vcams.push_back(cam)
		
	update_configuration_warnings()
	
	if vcams.size() == 0:
		return

	position = active.position

var col: Dictionary
@onready var space_state = get_world_2d().direct_space_state

func _get_configuration_warnings() -> PackedStringArray:
	if vcams.size() == 0:
		return ["CameraBrain2D must have at least one VirtualCamera2D as a child to work."]
	else:
		return []

func _process(delta):
	# TODO ugh
	vcams.clear()
	for cam in get_children():
		vcams.push_back(cam)
		
	update_configuration_warnings()
		
	if vcams.size() == 0:
		return
		
	if not Engine.is_editor_hint():
		for node in active.find_children("", "CameraScript3D"):
			node.execute(delta)
	
	position = active.position \
		+ active.orbiting.offset \
		+ polar_to_xy(active.orbiting.radius, active.orbiting.angle)
		
	rotation = active.location_rotation + active.orbiting.rotation
		
	zoom = Vector2(active.orbiting.zoom, active.orbiting.zoom)

static func polar_to_xy(radius: float, angle: float) -> Vector2:
	return Vector2(radius * cos(angle), radius * sin(angle))
