class_name LockpickSmallMinigameSpawner
extends MinigameSpawner


func create_minigame() -> Minigame:
	var minigame_instance: Minigame = load("res://Src/Minigames/LockpickSmallMinigame/LockpickSmallMinigame.tscn").instance()
	
	Global.game_manager.levelNode.get_node("HUD").add_child(minigame_instance)
	minigame_instance.owner_obj = self
	
	# sets position to bottom center of the screen
	var screen_bottom_center = Global.screen_bottom_center
	minigame_instance.global_position = screen_bottom_center
	
	return minigame_instance
	

func run_minigame(_door_name, _lock_level, _run_anim):
	if can_make_minigame and minigame == null:
		# Creates a minigame and opens it 
		minigame = create_minigame()
		minigame.door_name = _door_name
		minigame.difficulty = _lock_level #1 2 used for diff
		minigame.run_anim = _run_anim
		#warning-ignore:return_value_discarded
		minigame.connect("result_changed", self, "_on_minigame_result_changed")
		minigame.open()

#off porccess pass cuz we will call this from door itself
func _base_process(delta):
	pass
