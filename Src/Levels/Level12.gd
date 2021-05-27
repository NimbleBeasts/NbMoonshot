extends "res://Src/Levels/BaseLevel.gd"



func _ready():
	# (Re)Set visibility
	$HideWalls.modulate = Color(1, 1, 1, 1)
	$Foreground/HideRails.modulate = Color(1, 1, 1, 1)
	$HideWalls.show()
	$Foreground/HideRails.show()





func _on_EnterBuilding_body_entered(body):
	if body.is_in_group("Player"):
		if $HideWalls.modulate != Color(1, 1, 1, 1):
			pass
		else:
			$AnimationPlayer.play("hide")


func _on_ExitBuilding_body_entered(body):
	if body.is_in_group("Player"):
		if $HideWalls.modulate != Color(1, 1, 1, 0):
			pass
		else:
			$AnimationPlayer.play_backwards("hide")
