extends Resource
class_name Orbiting2D

@export var radius: float = 0
@export_range(-TAU/2, TAU/2) var angle: float = 0
@export var offset: Vector2 = Vector2(0, 0)
@export var zoom: float = 1
@export var rotation: float = 0 # radians
