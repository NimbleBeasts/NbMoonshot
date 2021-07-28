extends "res://Src/Levels/BaseLevel.gd"




# Workaround to block item for small ladders
func _on_Detector_body_entered(body):
	if body.is_in_group("Player"):
		$LevelObjects/ThinAreas/LadderValutHole/BlockSolution/MovingBlockShape.position = Vector2(0, 0)
