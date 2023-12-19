@tool
extends CameraScript3D

# TODO
# NO DEBERÍA EJECUTARSE ANTES DE VIRTUAL CAMERA?¿?¿ ESTÁ DESPUÉS
func PASSexecute(delta):
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
		virtual_cam.horizontal_damper.set_parameters(1, 2, 3)
		
	if Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down"):
		virtual_cam.horizontal_damper.set_parameters(1, 1, 0)
