extends NPC


func _ready() -> void:
	interacted_counter = Global.game_manager.boss_interaction_counter
	connect("read_all_dialog", self, "_on_read_all_dialog")
	Events.connect("tutorial_finished", self, "_on_tutorial_finished")

# gets called when player goes through one iteration of the dialog
func _on_read_all_dialog() -> void:
	var dialogue := load_dialogue()
	if has_dialogue("quest", str(interacted_counter)):
		Global.game_manager.quest_index = int(get_dialogue("quest", str(interacted_counter))["level_index"])


func _on_tutorial_finished() -> void:
	Global.game_manager.boss_interaction_counter += 1
	interacted_counter += 1
