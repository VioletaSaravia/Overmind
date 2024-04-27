extends Resource
class_name Orbiting2D

## Distance from location.
@export var radius: float = 0
## Angle from location.
@export_range(-TAU/2, TAU/2) var angle: float = 0
## Orbiting center offset.
@export var offset: Vector2 = Vector2(0, 0)
## Camera zoom.
@export var zoom: float = 1
## Camera rotation.
@export var rotation: float = 0 # radians
