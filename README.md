# Overmind v0.5.0

Overmind is a camera system based around virtual camera nodes that hold information about location, target and translation. It does not aim to be a clone or replacement of its inspiration, but rather to adapt its main workflow into a simple, indie-oriented package that follows the godot philosophy: Everything is a node, runs fast, and the provided features are simple but complete, and can be easily extended via gdscript.

## Features

- Easily manage a collection of virtual cameras and their transitions.
- Define cameras in terms of their location, with support for orbiting parameters (rotation, displacement, pivoting, etc.) and their target (Either custom or any Node3D).
- Procedurally animate cameras by manipulating how they respond to the movement of the location or their target: add easing, smoothing, bounce, and other effects.
- [Coming soon(tm)] Define transitions between cameras as splines or dampened movement between them.

## How to Use

1) Add Overmind to your *res://addons/* folder.
2) Add one of either CameraBrain2D or CameraBrain3D to your scene.
3) Add any number of VirtualCamera nodes as subnodes to the CameraBrain. Check out the examples under *examples/virtual cameras/*.
4) Set the parameters for each virtual camera, and set its follow node and optional target node.

## FAQ

### DampedValue? What is that?

Overmind allows you to procedurally animate your camera's movement in terms of three parameters F, Z and R. For a detailed explanation of this method, I recommend checking out the following video: https://www.youtube.com/watch?v=KPoeNZZ6H4s. The "DampedValue" resource is an implementation of the code in this video.

## TODO List

- Transitions (splines, tweens, instant)
- Target deadzones
- [1/3] Demo cameras
