extends Node
@onready var cam: VirtualCamera3D

@export var yaw_speed: float = .5

func _process(delta):
	if !Input.is_action_pressed("lateral_lock"):
		if Input.is_action_pressed("move_right"):
			cam.active.orbiting.yaw += yaw_speed * delta
		if Input.is_action_pressed("move_left"):
			cam.active.orbiting.yaw -= yaw_speed * delta
