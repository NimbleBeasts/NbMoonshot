extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	yield(get_tree().create_timer(2.0), "timeout")
	$AnimationPlayer.play("OpenBox")
	yield(get_tree().create_timer(1.0), "timeout")
	$StaticBody2D/CollisionShape2D.disabled = true
	$StaticBody2D2/CollisionShape2D.disabled = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
