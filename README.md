# Overmind 0.8.0

Overmind is a camera system based around virtual camera nodes that hold information about location, target and translation. It aims to be a simple, gamejam- and indie-oriented package that follows the godot philosophy: Everything is a node, gets you started fast, the provided features are simple but complete for 80% of use cases, and can be easily extended via gdscript if insufficient.

### What is it good for?

- Games that make a simple or standard use of cameras.
- Games with cutscenes or transitions.
- Games that require smooth camera movement and transitions (Action, racing, adventure, etc.)

### What is it *not* good for?

- Games that need 6-DOF, complex pivots or whose ground "shifts" in space. To achieve simplicity, Overmind is built around certain assumptions that almost no game violates, e.g., that the gravity will always point in the same direction. Though possible, I wouldn't try making Super Mario Galaxy with this plugin.

## Features

- Easily manage a collection of virtual cameras and their transitions.
- Define cameras in terms of their location, with support for orbiting parameters (rotation, displacement, pivoting, etc.) and their target (Either custom or any Node3D).
- Procedurally animate cameras by manipulating how they respond to the movement of the location or their target: add easing, smoothing, bounce, and other effects.
- Define transitions between cameras as paths or dampened movement between them.

## How to Use

1) Add Overmind to your *res://addons/* folder.
2) Add one of either CameraBrain2D or CameraBrain3D to your scene.
3) Add any number of VirtualCamera nodes as subnodes to the CameraBrain. Check out the examples under *examples/virtual cameras/*.
4) Set the parameters for each virtual camera, and set its follow node and optional target node.

## FAQ

### DampedValue? What is that?

Overmind allows you to procedurally animate your camera's movement in terms of three parameters F, Z and R. For a detailed explanation of this method, I recommend checking out the following video: https://www.youtube.com/watch?v=KPoeNZZ6H4s. The "DampedValue" resource is an implementation of the code in this video.

## Pending

- [DONE] Follow Node3D rotation
- Transitions (splines, tweens, instant)
- Target deadzones
- [1/3] Demo cameras
- Eyeball Node tree icon

## Credits

- Eye by Minh Nguyen Tri [CC-BY](https://creativecommons.org/licenses/by/3.0/) via [Poly Pizza](https://poly.pizza/m/5k9K6C4nQPw)
