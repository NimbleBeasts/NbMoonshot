extends NPC


func _ready() -> void:
	if Global.gameState.level.id == 0:
		Global.gameState.level.missionIsTutorial = true

	interacted_counter = Global.gameState.level.id
	Events.connect("tutorial_finished", self, "_on_tutorial_finished")

# gets called when player goes through one iteration of the dialog
func onReadAllDialogue() -> void:
	.onReadAllDialogue() # calls super class function
	if has_dialogue("quest", str(interacted_counter)):
		Global.game_manager.quest_index = int(get_dialogue("quest", str(interacted_counter))["level_index"])
		Events.emit_signal("level_hint", tr("MISSION_TITLE" + str(Global.game_manager.quest_index)))

		# game state stuff for saving
		if Global.game_manager.quest_index != 0:
			Global.gameState["level"]["hasActiveMission"] = true
			Global.gameState["level"]["missionIsTutorial"] = false
			Global.gameState["level"]["lastActiveMission"] = Global.game_manager.quest_index
			
			
func _on_tutorial_finished() -> void:
	Global.gameState.level.id = 1
	interacted_counter = 1
