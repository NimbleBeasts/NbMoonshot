extends Node2D 

var isUsed = false

export(int) var keyPadCode = 0
export(Types.Minigames) var minigameType = Types.Minigames.Keypad
export(NodePath) var openTarget = null

const lockpickSpawnerScript := preload("res://Src/Minigames/LockpickMinigame/LockpickMinigameSpawner.gd")
const keypadSpawnerScript := preload("res://Src/Minigames/KeypadMinigame/KeypadMinigameSpawner.gd")


func getProgessState():
	print("getProgressState called")
	return isUsed
	
func _ready():
	#warning-ignore:return_value_discarded
	
	match minigameType:
		Types.Minigames.Keypad:
			$MinigameSpawner.set_script(keypadSpawnerScript)
			$MinigameSpawner.connect("minigame_succeeded", self, "openTresor")
			$MinigameSpawner.lock_code = keyPadCode
		Types.Minigames.Lockpick:
			$MinigameSpawner.set_script(lockpickSpawnerScript)
			$MinigameSpawner.connect("minigame_succeeded", self, "openTresor")


func openTresor():
	$Sprite.frame = 1
	isUsed = true
	Events.emit_signal("tutorial_finished")
	if openTarget:
		get_node(openTarget).open()
