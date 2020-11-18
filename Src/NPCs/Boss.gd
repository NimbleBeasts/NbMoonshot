extends NPC


func _ready() -> void:
	interacted_counter = Global.gameState["interactionCounters"]["boss"]
	Events.connect("tutorial_finished", self, "_on_tutorial_finished")

# gets called when player goes through one iteration of the dialog
func onReadAllDialogue() -> void:
	var dialogue := load_dialogue()
	.onReadAllDialogue() # calls super class function
	if has_dialogue("quest", str(interacted_counter)):
		Global.game_manager.quest_index = int(get_dialogue("quest", str(interacted_counter))["level_index"])
		
		# game state stuff for saving
		if Global.game_manager.quest_index != 0:
			Global.gameState["level"]["hasActiveMission"] = true
			Global.gameState["level"]["missionIsTutorial"] = false
			Global.gameState["level"]["lastActiveMission"] = Global.game_manager.quest_index
		else:
			Global.gameState["level"]["missionIsTutorial"] = true

			
func _on_tutorial_finished() -> void:
	Global.gameState["interactionCounters"]["boss"] += 1
	interacted_counter += 1
