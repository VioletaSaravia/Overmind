# CineCam

Cinecam is a camera system based around vritual camera nodes that hold information about location, target and translation. It does not aim to be a clone or replacement of its inspiration, but rather to adapt its main workflow into a simple, indie-oriented package that follows the godot philosophy: Everything is a node, runs fast, and the provided features are simple but complete, and can be easily extended via gdscript.

## Features

- Easily manage a collection of virtual cameras with support for transitions
- Define cameras in terms of their location, with support for orbiting parameters (rotation, displacement, pivoting, etc.) and their target (Either custom or any Node3D).
- Procedurally animate cameras by manipulating how they respond to the movement of the location or their target: add easing, smoothing, bounce, and other effects.
- [Coming soon(tm)] Define transitions between cameras as splines or dampened movement between them.

## How to Use

1) Add CineCam to your *res://addons/* folder.
2) Add one of either CameraBrain2D or CameraBrain3D to your scene.
3) Add any number of VirtualCamera nodes as subnodes to the CameraBrain
4) Set the parameters for each virtual camera.

## TODO List

- [DONE] Individual axis dampening
- Rotation dampening
- Transitions (splines, dampened)
- Target deadzones
- [DONE] Change dampening without reloading game
- Demo cameras
