extends NPC

var interacted_counter: int = 1


func interact():
	var dialogue := load_dialogue()
	if not dialogue.empty() and dialogue.has(str(interacted_counter)):
		print(dialogue[str(interacted_counter)]["text"])
		interacted_counter += 1
