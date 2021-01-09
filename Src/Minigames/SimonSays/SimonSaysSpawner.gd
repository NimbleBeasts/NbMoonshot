extends MinigameSpawner


func create_minigame() -> Minigame:
	var minigame_instance: Minigame = load("res://Src/Minigames/SimonSays/SimonSays.tscn").instance()
	
	Global.game_manager.levelNode.get_node(holderNodeInLevel).add_child(minigame_instance)
	minigame_instance.owner_obj = self
	
	# sets position to bottom center of the screen
	var screen_bottom_center = Global.screen_bottom_center
	minigame_instance.global_position = screen_bottom_center
	
	return minigame_instance
	
	
func run_minigame(_door_name):
	if can_make_minigame and minigame == null:
		# Creates a minigame and opens it 
		minigame = create_minigame()
		minigame.door_name = _door_name
		#warning-ignore:return_value_discarded
		minigame.connect("result_changed", self, "_on_minigame_result_changed")
		minigame.open()
