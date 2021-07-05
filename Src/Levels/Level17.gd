extends "res://Src/Levels/BaseLevel.gd"


var lowered = false
var objective = false
var inObjectiveArea = false

func _ready():
	set_process_unhandled_input(false)


func _input(event: InputEvent) -> void:
	if objective:
		if event.is_action_pressed("interact") and Global.player.canInteract:
			$LevelObjects/ExtractionZone/AnimationPlayerEnd.play("end")
	elif inObjectiveArea:
		pass

func unlock(): #Button callback
	if not lowered:
		lowered = true
		$SpriteWalls/Capsule/AnimationPlayer.play("lower")


func _on_AnimationPlayerEnd_animation_finished(anim_name):
	$LevelObjects/ExtractionZone.manualLevelFinish()

func _on_ExitArea_body_entered(body):
	if body.is_in_group("Player"):
		set_process_input(true)

func _on_ExitArea_body_exited(body):
	if body.is_in_group("Player"):
		set_process_input(false)


func _on_Objective_body_entered(body):
	if body.is_in_group("Player"):
		inObjectiveArea = true
		set_process_input(true)


func _on_Objective_body_exited(body):
	if body.is_in_group("Player"):
		inObjectiveArea = false
		set_process_input(false)
