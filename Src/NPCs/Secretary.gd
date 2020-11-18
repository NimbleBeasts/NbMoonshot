extends NPC

func _ready() -> void: 
	interacted_counter = Global.gameState["interactionCounters"]["secretary"]
