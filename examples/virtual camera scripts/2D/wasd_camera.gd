extends CharacterBody2D

func _ready():
	$"..".follow_node = $"."

@export var speed: float = 2000
@export var margin: float = 0.01

func _process(delta):
	
	# WASD MOVEMENT
	var direction: Vector2 = Input.get_vector(
		"move_left", "move_right", "move_up", "move_down")
		
	if direction:
		# isometric y-axis compression
		direction.y *= 0.5
		velocity = direction.normalized() * speed
	else:
		velocity = Vector2.ZERO
		
	# EDGE SLIDE
	var screen_size: Vector2 = get_viewport_rect().size	
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	
	if mouse_pos.x < screen_size.x * margin:
		velocity += Vector2.LEFT * speed
	if mouse_pos.x > screen_size.x * (1 - margin):
		velocity += Vector2.RIGHT * speed
	if mouse_pos.y < screen_size.y * margin:
		velocity += Vector2.UP * speed * 0.5
	if mouse_pos.y > screen_size.y * (1 - margin):
		velocity += Vector2.DOWN * speed * 0.5
	
	move_and_slide()
