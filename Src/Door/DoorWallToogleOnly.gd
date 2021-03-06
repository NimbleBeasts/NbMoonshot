extends Node2D


export var closed = true

func _ready():
	if closed:
		$Sprite.frame = 0
		$StaticBody2D/CollisionShape2D.disabled = false
	else:
		$Sprite.frame = 2
		$StaticBody2D/CollisionShape2D.disabled = true
	pass


func toggleState():
	if closed:
		$AnimationPlayer.play("open_door")
		$StaticBody2D/CollisionShape2D.disabled = true
		closed = false
		$DoorSounds/MetalOpen.play()
	else:
		$AnimationPlayer.play_backwards("open_door")
		$StaticBody2D/CollisionShape2D.disabled = false
		closed = true
		$DoorSounds/MetalClose.play()
	
