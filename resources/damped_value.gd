@tool
class_name DampedValue extends Resource

@export var enabled: bool = true
@export var started: bool = false

## Frequency at which the value oscillates, in Hz.
@export_range(0.1, 5) var f: float = 1 :
	set(value):
		f = value
		_set_parameters(value)

## Damping Coefficient, describes how the system settles on target.
@export_range(0, 2) var z: float = 1 :
	set(value):
		z = value
		_set_parameters(f, value)

## Initial response of the system. At 1, the system reacts immediately to input.
## Above 1, the system overshoots the target. Below 0, the motion is anticipated.
@export_range(-5, 5) var r: float = 0 :
	set(value):
		r = value
		_set_parameters(f, z, value)

var _xp: Variant # Previous input
var _yd: Variant # State variable
var _y: Variant # State variable

var _k1: float
var _k2: float
var _k3: float

var value: Variant: 
	get: return _y
	
func start(x0: Variant) -> void:
	_y = x0
	_yd = x0
	_xp = x0
	
	_k1 = z / (PI * f)
	_k2 = 1 / ((2 * PI * f) * (2 * PI * f))
	_k3 = r * z / (2 * PI * f)
	
	started = true
	
# TODO INEFFICIENT
func set_parameters(_f: float = f, _z: float = z, _r: float = r) -> void:
	f = _f
	z = _z
	r = _r

func _set_parameters(_f: float = f, _z: float = z, _r: float = r) -> void:
	_k1 = z / (PI * f)
	_k2 = 1 / ((2 * PI * f) * (2 * PI * f))
	_k3 = r * z / (2 * PI * f)
	
func update(delta: float, x: Variant) -> void:
	if not started:
		start(x)
		started = true
		return

	if not enabled:
		_y = x # TODO TEST
		return

	var xd = (x - _xp) / delta
	_xp = x
	
	_y = _y + delta * _yd

	var k2_stable = maxf(_k2, 1.1 * (delta * delta / 4 + delta * _k1 / 2))
	_yd = _yd + delta * (x + _k3 * xd - _y - _k1 * _yd) / k2_stable
