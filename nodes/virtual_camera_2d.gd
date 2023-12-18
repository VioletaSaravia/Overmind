@icon("res://addons/Overmind/assets/camera_blue.svg")
## Defines the parameters of a 2D virtual camera to be used by a CameraBrain2D node.
class_name VirtualCamera2D extends Node2D

@onready var location: Vector2 = Vector2.ZERO
@onready var cam: CameraBrain2D = $".."
var x_damper: DampedValue
var y_damper: DampedValue

@export_group("Settings")
## Which Node2D's position(s) will be used to set the camera location.
@export var follow_node: Array[Node2D]

@export_group("Damping Settings")
@export var x_location_damp: bool = true
@export_range(0.1, 5) var x_location_f: float = 1 : set = _set_loc_xf
@export_range(0, 2) var x_location_z: float = 1 : set = _set_loc_xz
@export_range(-5, 5) var x_location_r: float = 0 : set = _set_loc_xr

func _set_loc_xf(f: float):
	x_location_f = f
	if x_damper:
		x_damper.set_parameters(f)
	
func _set_loc_xz(z: float):
	x_location_z = z
	if x_damper:
		x_damper.set_parameters(x_location_f, z)
	
func _set_loc_xr(r: float):
	x_location_r = r
	if x_damper:
		x_damper.set_parameters(x_location_f, x_location_z, r)

@export var y_location_damp: bool = true
@export_range(0.1, 5) var y_location_f: float = 1 : set = _set_loc_yf
@export_range(0, 2) var y_location_z: float = 1 : set = _set_loc_yz
@export_range(-5, 5) var y_location_r: float = 0 : set = _set_loc_yr

func _set_loc_yf(f: float):
	y_location_f = f
	if y_damper:
		y_damper.set_parameters(f)
	
func _set_loc_yz(z: float):
	y_location_z = z
	if y_damper:
		y_damper.set_parameters(y_location_f, z)
	
func _set_loc_yr(r: float):
	y_location_r = r
	if y_damper:
		y_damper.set_parameters(y_location_f, y_location_z, r)

@export_group("Orbiting Settings")
@export_range(0, 2000) var radius: float = 0
@export_range(0, TAU) var angle: float = 0
@export var offset: Vector2 = Vector2(0, 0)

func _ready():
	process_priority = 998
	
	if follow_node.size() == 0:
		# printerr("Follow Node array contains no nodes.")
		return
		
	location = follow_node[0].position
	
	x_damper = DampedValue.new()
	y_damper = DampedValue.new()

func _process(delta):
	var new_location: Vector2 = follow_node[0].position
	
	for n in follow_node:
		new_location = lerp(new_location, n.position, 0.5)
	
	location = Vector2(
		x_damper.update_motion(delta, new_location.x) 
			if x_location_damp else new_location.x,
		y_damper.update_motion(delta, new_location.y) 
			if y_location_damp else new_location.y,
		)
