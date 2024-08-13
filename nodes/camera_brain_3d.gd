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
	
	position = active.position
	look_at(active.targeting)
	rotate(quaternion * Vector3.FORWARD, active.rotating)
