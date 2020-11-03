class_name Player
extends KinematicBody2D

var direction: Vector2
var velocity: Vector2

export var max_speed: int = 100
export var acceleration: int = 600
export var friction: int = 600


func _physics_process(delta: float) -> void:
	# movement code
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction = direction.normalized()
	
	# moves with acceleration or friction depending on whether player has stopped
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
	velocity = move_and_slide(velocity)
