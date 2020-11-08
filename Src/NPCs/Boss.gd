extends NPC

var interacted_counter: int = 1

# function gets called when you get close to this and press "interact" in input map
func _on_player_interacted() -> void:
	var dialogue := load_dialogue()
	if not dialogue.empty() and dialogue.has(str(interacted_counter)):
		print(dialogue[str(interacted_counter)]["text"])
		interacted_counter += 1
