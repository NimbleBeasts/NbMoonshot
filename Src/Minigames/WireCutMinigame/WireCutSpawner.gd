extends MinigameSpawner
class_name WireCutSpawner

var wire_cuts: Array = []
var enums = [Types.WireColors.Red, Types.WireColors.Blue, Types.WireColors.Green, Types.WireColors.Purple]
export var countdownTime: int = 12

func _ready() -> void:
	randomize()
	var thing = 0
	while thing < 2:
		var toAppend = enums[randi() % enums.size()]
		if not toAppend in wire_cuts:
			wire_cuts.append(toAppend)
		else:
			thing -= 1
		thing += 1

func create_minigame() -> Minigame:
	var minigame_instance: Minigame = load("res://Src/Minigames/WireCutMinigame/WireCutMinigame.tscn").instance()
	minigame_instance.goal_cuts = wire_cuts
	minigame_instance.countdown = countdownTime
	game_manager.levelNode.get_node("HUD").add_child(minigame_instance)
	minigame_instance.owner_obj = self # sets owner obj to self so it has a reference to this node

	# sets position to bottom center of the screen
	minigame_instance.global_position = Global.screen_bottom_center
	
	return minigame_instance

	
