class_name Throwable
extends KinematicBody2D

export var gravity: float
var velocity: Vector2
var canMakeSound: bool = true


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	rotation = velocity.angle()
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity / 5
		velocity = velocity.bounce(collision.normal)
		if canMakeSound:
			Events.emit_signal("audio_level_changed", Types.AudioLevels.LoudNoise, global_position)
			canMakeSound = false

		
func throw(initialVelocity: Vector2) -> void:
	set_physics_process(true)
	velocity = initialVelocity