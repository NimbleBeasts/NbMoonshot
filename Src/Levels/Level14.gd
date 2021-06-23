extends "res://Src/Levels/BaseLevel.gd"


var player = null
var finished = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and Global.player.canInteract:
		sabotage()


func _on_MissionGoal_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		set_process_input(true)


func _on_MissionGoal_body_exited(body):
	if body.is_in_group("Player"):
		player = null
		set_process_input(false)


func getProgessState():
	return finished

func sabotage():
	if not finished:
		finished = true
		$LevelObjects/Objects/MissionGoal/WireCut.play()
		Events.emit_signal("hud_game_hint", "Sabotage completed!")
