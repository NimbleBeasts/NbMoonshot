class_name Throwable
extends KinematicBody2D

const TIMER_PHYSICS_DISABLE = 0.25
const TIMER_QUEUE_FREE = 3

export var gravity: float
var velocity: Vector2
var canMakeSound: bool = true

var timerDisablePhysics
var timerRemove
var stopPosition: Vector2

onready var collisionShape = $CollisionShape2D


func _ready() -> void:
	set_physics_process(false)
	$AnimationPlayer.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")

	timerDisablePhysics = Timer.new()
	timerDisablePhysics.one_shot = true
	timerDisablePhysics.wait_time = TIMER_PHYSICS_DISABLE
	timerDisablePhysics.connect("timeout", self, "disablePhysics")
	self.add_child(timerDisablePhysics)

	timerRemove = Timer.new()
	timerRemove.one_shot = true
	timerRemove.wait_time = TIMER_QUEUE_FREE
	timerRemove.connect("timeout", self, "remove")
	self.add_child(timerRemove)
	
	$Sprite.modulate = Color(1, 1, 1, 1)


func disablePhysics():
	set_physics_process(false)

	
func remove():
	$AnimationPlayer.play("fadeout")
	timerRemove.disconnect("timeout", self, "remove")


func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	# global_position += velocity * delta
	var collision = move_and_collide(velocity * delta)
	if collision:
		# if collides, velocity divides and bounces
		rotation_degrees = 0
		velocity /= 5
		velocity = velocity.bounce(collision.normal)

	# stopPosition is the player's foot, this is to stop the obj
	# if global_position.y > stopPosition.y:
	# 	rotation_degrees = 0
	# 	velocity = Vector2(0,0)
		if canMakeSound:
			Events.emit_signal("audio_level_changed", Types.AudioLevels.LoudNoise, global_position, self)
			canMakeSound = false
		
		if not timerRemove.time_left:
			if $Sprite.hframes > 1:
				$Sprite.frame = 1
			
			timerRemove.start()
			# disablePhysics()


func throw(initialVelocity: Vector2) -> void:
	set_physics_process(true)
	velocity = initialVelocity


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()

