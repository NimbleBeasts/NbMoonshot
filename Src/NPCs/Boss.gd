extends NPC


func _ready() -> void:
	interacted_counter = Global.game_manager.boss_interaction_counter
	Events.connect("tutorial_finished", self, "_on_tutorial_finished")

# gets called when player goes through one iteration of the dialog
func _onReadAllDialogue() -> void:
	var dialogue := load_dialogue()
	._onReadAllDialogue() # calls super class function
	if has_dialogue("quest", str(interacted_counter)):
		Global.game_manager.quest_index = int(get_dialogue("quest", str(interacted_counter))["level_index"])

		if Global.game_manager.quest_index != 0:
			Global.gameState["level"]["hasActiveMission"] = true 
			Global.gameState["level"]["lastActiveMission"] = Global.game_manager.quest_index
		else:
			Global.gameState["level"]["missionIsTutorial"] = true

			
		print(Global.gameState)

func _on_tutorial_finished() -> void:
	Global.game_manager.boss_interaction_counter += 1
	interacted_counter += 1
