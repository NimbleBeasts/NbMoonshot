extends NPC

func _ready() -> void: 
	interacted_counter = Global.gameState.level.id
	Events.connect("tutorial_finished", self, "onTutorialFinished")

	
func onTutorialFinished() -> void:
	Global.gameState.level.id += 1
	interacted_counter += 1
	
