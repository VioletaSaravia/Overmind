@tool
extends CameraScript3D

@export var cam_turn_speed: float = 2

func execute(delta):
	var manual_yaw := Input.get_axis("turn_left", "turn_right")
	cam.active.orbiting.yaw += cam_turn_speed * manual_yaw * delta
	
	var manual_pitch := Input.get_axis("look_up", "look_down")
	cam.active.orbiting.pitch += cam_turn_speed * manual_pitch * delta
	cam.active.orbiting.pitch = clamp(cam.active.orbiting.pitch, -TAU/4 + 0.4, TAU/4 - 0.8)
