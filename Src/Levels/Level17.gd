extends "res://Src/Levels/BaseLevel.gd"


var lowered = false

func unlock(): #Button callback
	if not lowered:
		lowered = true
		$SpriteWalls/Capsule/AnimationPlayer.play("lower")
