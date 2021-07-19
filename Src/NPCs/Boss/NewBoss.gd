extends NewNPC


func _ready() -> void:
	if Global.gameState.level.id == 0:
		Global.gameState.level.missionIsTutorial = true

	setInteractedCounter(Global.gameState.level.id)
	Events.connect("tutorial_finished", self, "_on_tutorial_finished")

# gets called when player goes through one iteration of the dialog
func checkForQuests() -> void:
	.checkForQuests() # calls super class function
	if currentBranch.has("quest"):
		Global.game_manager.quest_index = int(currentBranch["quest"])
		Events.emit_signal("level_hint", tr("MISSION_TITLE" + str(Global.game_manager.quest_index)))

		# game state stuff for saving
		if Global.game_manager.quest_index != 0:
			Global.gameState["level"]["hasActiveMission"] = true
			Global.gameState["level"]["missionIsTutorial"] = false
			Global.gameState["level"]["lastActiveMission"] = Global.game_manager.quest_index
			
			
func _on_tutorial_finished() -> void:
	Global.gameState.level.id = 1
	setInteractedCounter(1)
