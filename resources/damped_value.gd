@tool
class_name DampedValue extends Resource

@export var enabled: bool = true
var started: bool = false

## Frequency (f) at which the value oscillates, in Hz.
@export_range(0.1, 5) var freq: float = 1:
	set(value):
		freq = value
		_set_parameters(value)

## Damping Coefficient (z), describes how the system settles on target.
@export_range(0, 2) var damp: float = 1:
	set(value):
		damp = value
		_set_parameters(freq, value)

## Initial response of the system (r). At 1, the system reacts immediately to input.
## Above 1, the system overshoots the target. Below 0, the motion is anticipated.
@export_range(-5, 5) var resp: float = 0:
	set(value):
		resp = value
		_set_parameters(freq, damp, value)

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
	
	_k1 = damp / (PI * freq)
	_k2 = 1 / ((2 * PI * freq) * (2 * PI * freq))
	_k3 = resp * damp / (2 * PI * freq)
	
	started = true
	
func set_parameters(_f: float = freq, _z: float = damp, _r: float = resp) -> void:
	freq = _f
	damp = _z
	resp = _r

func _set_parameters(_f: float = freq, _z: float = damp, _r: float = resp) -> void:
	_k1 = damp / (PI * freq)
	_k2 = 1 / ((2 * PI * freq) * (2 * PI * freq))
	_k3 = resp * damp / (2 * PI * freq)
	
func update(delta: float, x: Variant) -> void:
	if not started:
		start(x)
		started = true
		return

	if not enabled:
		_y = x
		return

	var xd = (x - _xp) / delta
	_xp = x
	
	_y = _y + delta * _yd

	var k2_stable = maxf(_k2, 1.1 * (delta * delta / 4 + delta * _k1 / 2))
	_yd = _yd + delta * (x + _k3 * xd - _y - _k1 * _yd) / k2_stable
