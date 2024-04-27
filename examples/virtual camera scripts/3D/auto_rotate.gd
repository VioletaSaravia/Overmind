@tool
extends Node
@onready var cam: VirtualCamera3D = $".."

func _ready():
	pass

func _process(delta):
	cam.orbiting.yaw += 1 * delta
