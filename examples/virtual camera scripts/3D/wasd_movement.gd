extends CameraScript3D

@export var move_speed: float = 2

func execute(delta):
	var movement = Input.get_vector("look_left", "look_right", "look_down", "look_up")
	cam.active.location += movement * move_speed * delta
