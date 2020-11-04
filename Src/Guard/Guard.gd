class_name Guard
extends KinematicBody2D

export var speed: int = 50
export var direction_change_time: float = 2
export var starting_direction: Vector2

var velocity: Vector2
var direction: Vector2
var moving_right: bool = true


func _ready() -> void:
	$DirectionChangeTimer.wait_time = direction_change_time
	$DirectionChangeTimer.start()
	direction = starting_direction 
	

func _process(delta: float) -> void:
	velocity = direction * speed
	velocity = move_and_slide(velocity)
	

func _on_DirectionChangeTimer_timeout():
	change_direction()
	

func change_direction() -> void:
	# flips moving_right, also flips the direction.x
	moving_right = not moving_right
	direction.x *= -1
	
