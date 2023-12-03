class_name Dampener extends Node

## Frequency, in Hz.
var _f: float
## Damping Coefficient, describes how the system settles on target.
var _z: float
## Initial response of the system. At 1, the system reacts immediately to input.
## Above 1, the system overshoots the target. Below 0, the motion is anticipated.
var _r: float

var xp: Variant
var yd: Variant
var y: Variant

var k1: float
var k2: float
var k3: float

func _init(x0: Variant, f: float = 1, z: float = 1, r: float = 0):
	y = x0
	yd = x0
	xp = x0
	
	_f = f
	_z = z
	_r = r
	
	k1 = _z / (PI * _f)
	k2 = 1 / ((2 * PI * _f) * (2 * PI * _f))
	k3 = _r * _z / (2 * PI * _f)
	
func set_parameters(f: float = _f, z: float = _z, r: float = _r):
	_f = f
	_z = z
	_r = r
	
	k1 = _z / (PI * _f)
	k2 = 1 / ((2 * PI * _f) * (2 * PI * _f))
	k3 = _r * _z / (2 * PI * _f)
	
func update_motion(delta: float, x: Variant) -> Variant:
	var xd = (x - xp) / delta
	xp = x
	
	y = y + delta * yd

	var k2_stable = maxf(k2, 1.1 * (delta * delta / 4 + delta * k1 / 2))
	yd = yd + delta * (x + k3 * xd - y - k1 * yd) / k2_stable
	
	return y
