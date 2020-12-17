extends KinematicBody2D

export var gravity: float
var velocity: Vector2


func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	velocity.y += gravity * delta
	rotation = velocity.angle()
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity / 5
		velocity = velocity.bounce(collision.normal)
		set_process(false)		

		
func throw(initialVelocity: Vector2) -> void:
	set_process(true)
	velocity = initialVelocity