extends Node2D 

func _ready():
	$KeypadMinigameSpawner.connect("minigame_succeeded", self, "openTresor")
	$KeypadMinigameSpawner.lock_code = 1337
	
func openTresor():
	$Sprite.frame = 1
