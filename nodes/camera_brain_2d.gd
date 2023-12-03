## Core node of CineCam for 2D scenes.
@tool
@icon("res://addons/CineCam/assets/brain_blue.svg")
class_name CameraBrain2D extends Camera2D


@export_group("Virtual Cameras")
var vcams: Array[VirtualCamera]
@export var current_cam: int: set = _set_cam

func _set_cam(cam: int):
	current_cam = cam % vcams.size()
	location_node = vcams[current_cam].get_child(0)
	target_node = vcams[current_cam].get_child(1)

var location_node: Node2D
var target_node: Node2D
var pedestal: float: get = _get_pedestal, set = _set_pedestal
var tilt: float: get = _get_tilt, set = _set_tilt
var track: float: get = _get_track, set = _set_track
var radius: float: get = _get_radius, set = _set_radius
var yaw: float: get = _get_yaw, set = _set_yaw
var pitch: float: get = _get_pitch, set = _set_pitch

func _get_pedestal() -> float:
	return vcams[current_cam].pedestal

func _get_tilt() -> float:
	return vcams[current_cam].tilt

func _get_track() -> float:
	return vcams[current_cam].track

func _get_radius() -> float:
	return vcams[current_cam].radius

func _get_yaw() -> float:
	return vcams[current_cam].yaw

func _get_pitch() -> float:
	return vcams[current_cam].pitch

func _set_pedestal(val: float):
	vcams[current_cam].pedestal = val

func _set_tilt(val: float):
	vcams[current_cam].tilt = val

func _set_track(val: float):
	vcams[current_cam].track = val

func _set_radius(val: float):
	vcams[current_cam].radius = val

func _set_yaw(val: float):
	vcams[current_cam].yaw = val

func _set_pitch(val: float):
	vcams[current_cam].pitch = val

func _ready():
	process_priority = 999

	for cam in get_children():
		vcams.push_back(cam)

	location_node = vcams[current_cam].get_child(0)
	target_node = vcams[current_cam].get_child(1)
	self.position = location_node.position
	self.rotation = location_node.rotation

func _process(delta):
	var location: Vector2 = location_node.position
	var target: Vector2 = target_node.position

# TODO
#	var local_track = quaternion * Vector2(track, 0, 0)
#	var local_pedestal = quaternion * Vector2(0, pedestal, 0)

#	self.position = location + local_pedestal + local_track \
#	+ get_orbit(radius, yaw, pitch)
#	var track_focus = target + get_orbit(0, yaw + -PI/2, 0)
#	self.look_at(track_focus + Vector3(0, tilt, 0) + local_track)

#func get_orbit(_radius: float, _yaw: float, _pitch: float) -> Vector3:
#	var ray := Vector3.FORWARD
#	ray = Quaternion(Vector3.UP, TAU - _yaw) * ray
#
#	var _pitch_axis := ray.cross(Vector3.UP)
#	ray = Quaternion(_pitch_axis, TAU - _pitch) * ray
#
#	return ray * - _radius
