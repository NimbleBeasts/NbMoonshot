extends Node2D


func _ready():
	yield(get_tree().create_timer(2.0), "timeout")
	$AnimationPlayer.play("OpenBox")
	yield(get_tree().create_timer(1.0), "timeout")
	$StaticBody2D/CollisionShape2D.disabled = true
	$StaticBody2D2/CollisionShape2D.disabled = true
	pass # Replace with function body.


