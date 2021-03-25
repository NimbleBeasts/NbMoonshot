class_name PipeMinigameSpawner
extends MinigameSpawner


func create_minigame() -> Minigame:
	var minigame_instance: Minigame = load("res://Src/Minigames/PipeMinigame/PipeMinigame.tscn").instance()

	game_manager.levelNode.get_node(minigameHolder).add_child(minigame_instance)
	minigame_instance.owner_obj = self # sets owner obj to self so it has a reference to this node
	
	# sets position to bottom center of the screen
	var screen_bottom_center = Global.screen_bottom_center
	minigame_instance.global_position = screen_bottom_center
	minigame_instance.open()

	return minigame_instance