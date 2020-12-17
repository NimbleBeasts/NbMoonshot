extends KinematicBody2D

export var gravity: float
var velocity: Vector2

func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	velocity.y += gravity * delta
	rotation = velocity.angle()
	move_and_slide(velocity)


func throw(initialVelocity: Vector2) -> void:
	set_process(true)
	velocity = initialVelocity