extends MinigameSpawner
class_name WireCutSpawner

export (Array, Types.WireColors) var wire_cuts: Array = []


func create_minigame() -> Minigame:
	var minigame_instance: Minigame = load("res://Src/Minigames/WireCutMinigame/WireCutMinigame.tscn").instance()
	minigame_instance.goal_cuts = wire_cuts
	game_manager.levelNode.get_node("HUD").add_child(minigame_instance)
	minigame_instance.owner_obj = self # sets owner obj to self so it has a reference to this node
	
	# sets position to bottom center of the screen
	minigame_instance.global_position = Global.screen_bottom_center
	
	return minigame_instance

	
