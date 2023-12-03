@tool
@icon("res://addons/Overmind/assets/transition_red.svg")
class_name CameraTransition extends Node

@export_category("Cameras")
@export var from_camera_type: CameraType
@export var from_camera: VirtualCamera3D
@export var to_camera_type: CameraType
@export var to_camera: VirtualCamera3D

@export_category("Transition")
@export var transition_type: TransitionType
@export var duration: float
## Frequency, in Hz. Makes the movement bounce as it settles in place.
@export_range(0, 5) var f: float = 1
## Damping Coefficient, describes how the system settles on target.
@export_range(0, 2) var z: float = 1
## Initial response of the system. At 1, the system reacts immediately to input.
## Above 1, the system overshoots the target. Below 0, the motion is anticipated.
@export_range(-5, 5) var r: float = 0

enum CameraType {
	Current,
	Specific
}

enum TransitionType {
	Path3D,
	Linear
}

func _ready():
	pass # Replace with function body.

func _process(delta):
	pass
