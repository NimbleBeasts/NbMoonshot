extends Control



func updateProgress():
	var level = Global.gameState["level"]["lastActiveMission"] + 1
	
	if level > Global.gameConstant.progress[0].size():
		_on_BaseButton_button_up()
		return
	
	
	
	updateValue($MissionProgressUsa, Types.LevelTypes.USA, level)
	updateValue($MissionProgressUssr, Types.LevelTypes.USSR, level)
	updateValue($MissionProgressUstria, Types.LevelTypes.Ustria, level)
	
	show()

	$MissionProgressUsa.startAnimation()
	$MissionProgressUssr.startAnimation()
	$MissionProgressUstria.startAnimation()

	$BaseButton.grab_focus()

func updateValue(node, country, level):
	var startValue = 0
	var endValue = 0
	
	if level > 0:
		startValue = Global.gameConstant.progress[country][level - 1]
		endValue = Global.gameConstant.progress[country][level]
		
	#TODO: invoke sabbotage decrease
	node.updateValue(startValue, endValue - startValue)

func _on_BaseButton_button_up():
	Events.emit_signal("hud_mission_progress_exited")
	hide()
