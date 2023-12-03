@icon("res://addons/Overmind/assets/camera_red.svg")
## Defines a the parameters of a virtual camera to be used by a CameraBrain node.
class_name VirtualCamera3D extends Node

var x_loc_dampener: Dampener
var v_loc_dampener: Dampener
var z_loc_dampener: Dampener

var x_target_dampener: Dampener
var v_target_dampener: Dampener
var z_target_dampener: Dampener

@export_group("General Settings")
## Set the target to be the same as the location. When enabled, all the location 
## settings affect the target too, and the target settings do nothing.
## Ideal for player cameras.
@export var target_equals_location: bool = true
## Whether the camera collides with objects or clips through them.
@export var collides: bool = true

@export_group("Location Settings")
## Which Node3D's position(s) will be used to set the camera location.
@export var location_follow_node: Array[Node3D]

@export_subgroup("Location Damping")
## Whether the location following is damped or not.
@export var h_location_damp: bool = true
## Frequency, in Hz. Makes the movement bounce as it settles in place.
@export_range(0.1, 5) var h_location_f: float = 1 : set = _set_loc_hf
## Damping Coefficient, describes how the system settles on target.
@export_range(0, 2) var h_location_z: float = 1 : set = _set_loc_hz
## Initial response of the system. At 1, the system reacts immediately to input.
## Above 1, the sstem overshoots the target. Below 0, the motion is anticipated.
@export_range(-5, 5) var h_location_r: float = 0 : set = _set_loc_hr

func _set_loc_hf(f: float):
	h_location_f = f
	if x_loc_dampener:
		x_loc_dampener.set_parameters(f)
		z_loc_dampener.set_parameters(f)
	
func _set_loc_hz(z: float):
	h_location_z = z
	if x_loc_dampener:
		x_loc_dampener.set_parameters(h_location_f, z)
		z_loc_dampener.set_parameters(h_location_f, z)
	
func _set_loc_hr(r: float):
	h_location_r = r
	if x_loc_dampener:
		x_loc_dampener.set_parameters(h_location_f, h_location_z, r)
		z_loc_dampener.set_parameters(h_location_f, h_location_z, r)		

## Whether the location following is damped or not.
@export var v_location_damp: bool = true
## Frequency, in Hz. Makes the movement bounce as it settles in place.
@export_range(0.1, 5) var v_location_f: float = 1 : set = _set_loc_vf
## Damping Coefficient, describes how the system settles on target.
@export_range(0, 2) var v_location_z: float = 1 : set = _set_loc_vz
## Initial response of the system. At 1, the system reacts immediately to input.
## Above 1, the sstem overshoots the target. Below 0, the motion is anticipated.
@export_range(-5, 5) var v_location_r: float = 0 : set = _set_loc_vr

func _set_loc_vf(f: float):
	v_location_f = f
	if v_loc_dampener:
		v_loc_dampener.set_parameters(f)
	
func _set_loc_vz(z: float):
	v_location_z = z
	if v_loc_dampener:
		v_loc_dampener.set_parameters(v_location_f, z)
	
func _set_loc_vr(r: float):
	v_location_r = r
	if v_loc_dampener:
		v_loc_dampener.set_parameters(v_location_f, v_location_z, r)

@export_subgroup("Orbiting Settings")
## Vertical rotation.
@export_range(-3, 3) var tilt: float = 1
# TODO: pan (Horizontal rotation)
## Horizontal displacement.
@export_range(-3, 3) var track: float = 0
## Vertical displacement.
@export_range(-1, 30) var pedestal: float = 1
## Horizontal pivoting around location.
@export_range(-TAU, TAU) var yaw: float
## Vertical pivoting around location.
@export_range(-TAU/4 + 0.1, TAU/4 - 0.1) var pitch: float = .3
## Distance from location.
@export_range(0, 20) var radius: float = 3

@export_group("Target Settings")
## Which Node3D's position(s) will be used to set the camera target.
@export var target_follow_node: Array[Node3D]

@export_subgroup("Target Damping")
## Whether the target following is damped or not.
@export var x_target_damp: bool = true
## Frequency, in Hz. Makes the movement bounce as it settles in place.
@export_range(0.1, 5) var x_target_f: float = 1 : set = _set_target_hf
## Damping Coefficient, describes how the system settles on target.
@export_range(0, 2) var x_target_z: float = 1 : set = _set_target_hz
## Initial response of the system. At 1, the system reacts immediately to input.
## Above 1, the system overshoots the target. Below 0, the motion is anticipated.
@export_range(-5, 5) var x_target_r: float = 0 : set = _set_target_hr

func _set_target_hf(f: float):
	x_target_f = f
	if x_target_dampener:
		x_target_dampener.set_parameters(f)
		z_target_dampener.set_parameters(f)
		
	
func _set_target_hz(z: float):
	x_target_z = z
	if x_target_dampener:
		x_target_dampener.set_parameters(x_target_f, z)
		z_target_dampener.set_parameters(x_target_f, z)
	
func _set_target_hr(r: float):
	x_target_r = r
	if x_target_dampener:
		x_target_dampener.set_parameters(x_target_f, x_target_z, r)
		z_target_dampener.set_parameters(x_target_f, x_target_z, r)

## Whether the target following is damped or not.
@export var v_target_damp: bool = true
## Frequency, in Hz. Makes the movement bounce as it settles in place.
@export_range(0.1, 5) var v_target_f: float = 1 : set = _set_target_vf
## Damping Coefficient, describes how the system settles on target.
@export_range(0, 2) var v_target_z: float = 1 : set = _set_target_vz
## Initial response of the system. At 1, the system reacts immediately to input.
## Above 1, the system overshoots the target. Below 0, the motion is anticipated.
@export_range(-5, 5) var v_target_r: float = 0 : set = _set_target_vr

func _set_target_vf(f: float):
	v_target_f = f
	if v_target_dampener:
		v_target_dampener.set_parameters(f)
	
func _set_target_vz(z: float):
	v_target_z = z
	if v_target_dampener:
		v_target_dampener.set_parameters(v_target_f, z)
	
func _set_target_vr(r: float):
	v_target_r = r
	if v_target_dampener:
		v_target_dampener.set_parameters(v_target_f, v_target_z, r)

@onready var location: Node3D = $Location
@onready var target: Node3D = $Target
@onready var cam: Camera3D = $".."

var test_dampener: Dampener

func _ready():
	process_priority = 998
	
	location.transform.basis = location_follow_node[0].basis
	
	if location_follow_node.size() == 0: 
		printerr("Location Follow Node array contains no nodes.")
		return
	
	x_loc_dampener = Dampener.new(
		location_follow_node[0].position.x, h_location_f, h_location_z, h_location_r)
	v_loc_dampener = Dampener.new(
		location_follow_node[0].position.y, v_location_f, v_location_z, v_location_r)
	z_loc_dampener = Dampener.new(
		location_follow_node[0].position.z, h_location_f, h_location_z, h_location_r)

	if target_equals_location:
		return

	if target_follow_node.size() == 0: 
		printerr("Target Follow Node array contains no nodes.")
		return
	
	x_target_dampener = Dampener.new(
		target_follow_node[0].position.x, x_target_f, x_target_z, x_target_r)
	v_target_dampener = Dampener.new(
		target_follow_node[0].position.y, v_target_f, v_target_z, v_target_r)
	z_target_dampener = Dampener.new(
		target_follow_node[0].position.z, x_target_f, x_target_z, x_target_r)
		

func _process(delta):
	var new_location_pos: Vector3 = location_follow_node[0].position
	
	for n in location_follow_node:
		new_location_pos = lerp(new_location_pos, n.position, 0.5)
	
	location.transform.basis = location_follow_node[0].basis
	
	location.position = Vector3(
		x_loc_dampener.update_motion(delta, new_location_pos.x) 
			if h_location_damp else new_location_pos.x,
		v_loc_dampener.update_motion(delta, new_location_pos.y) 
			if v_location_damp else new_location_pos.y,
		z_loc_dampener.update_motion(delta, new_location_pos.z) 
			if h_location_damp else new_location_pos.z,
		)
		
	if target_equals_location:
		target.position = location.position
		return

	var new_target_pos: Vector3 = target_follow_node[0].position
	for n in target_follow_node:
		new_target_pos = lerp(new_target_pos, n.position, 0.5)

	target.position = Vector3(
		x_target_dampener.update_motion(delta, new_target_pos.x)
			if x_target_damp else new_target_pos.x,
		v_target_dampener.update_motion(delta, new_target_pos.y)
			if v_target_damp else new_target_pos.y,
		z_target_dampener.update_motion(delta, new_target_pos.z)
			if x_target_damp else new_target_pos.z,
		)
