extends Node2D
var stoped = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("FanWorking")
	pass # Replace with function body.

func toggleState():
	if stoped:
		stoped = false
		$AnimationPlayer.playback_speed = 7
		$AnimationPlayer.play("FanWorking")
		$StaticBody2D/CollisionShape2D.disabled = false
	else:
		stoped = true
		$AnimationPlayer.playback_speed = 0
		$StaticBody2D/CollisionShape2D.disabled = true
		$AnimationPlayer.stop()
