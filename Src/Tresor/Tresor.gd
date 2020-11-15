extends Node2D 

var isUsed = false

export(int) var keyPadCode = 0
export(Types.Minigames) var minigameType = Types.Minigames.Keypad


func getProgessState():
	return isUsed

func _ready():
	#warning-ignore:return_value_discarded
	$KeypadMinigameSpawner.connect("minigame_succeeded", self, "openTresor")
	$KeypadMinigameSpawner.lock_code = keyPadCode
	
func openTresor():
	$Sprite.frame = 1
	isUsed = true
