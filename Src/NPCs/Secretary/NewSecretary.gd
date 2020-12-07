extends NewNPC


func _ready() -> void: 
	setInteractedCounter(Global.gameState["interactionCounters"]["secretary"])
	Events.connect("tutorial_finished", self, "onTutorialFinished")

	
func onTutorialFinished() -> void:
	Global.gameState["interactionCounters"]["secretary"] = 1
	setInteractedCounter(1)