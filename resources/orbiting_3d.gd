extends Resource
class_name Orbiting3D

## Distance from location.
@export_range(0, 20) var dolly: float = 3
## Vertical rotation.
@export_range(-3, 3) var tilt: float = 1
## Horizontal rotation
@export_range(-3, 3) var pan: float = 0
## Horizontal displacement.
@export_range(-3, 3) var track: float = 0
## Vertical displacement.
@export_range(-1, 30) var pedestal: float = 1
## Horizontal pivoting around location.
@export_range(-TAU, TAU) var yaw: float
## Vertical pivoting around location.
@export_range(-TAU/4 + 0.1, TAU/4 - 0.1) var pitch: float = .3
## Rotation of the camera along its longitudinal axis.
@export_range(- TAU / 2, TAU / 2) var roll: float = 0
