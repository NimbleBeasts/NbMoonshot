extends Node2D 

var isUsed = false

func getProgessState():
	return isUsed

func _ready():
	#warning-ignore:return_value_discarded
	$KeypadMinigameSpawner.connect("minigame_succeeded", self, "openTresor")
	$KeypadMinigameSpawner.lock_code = 1337
	
func openTresor():
	$Sprite.frame = 1
	isUsed = true
