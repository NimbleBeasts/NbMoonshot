class_name Doll
extends KinematicBody2D

#warning-ignore-all:unused_class_variable
var isStunned: bool = false #this is used from player node


func stun(_d):
	$AnimationPlayer.play("tasered")
	
