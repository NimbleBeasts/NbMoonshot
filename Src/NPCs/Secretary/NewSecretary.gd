extends NewNPC

var loveLevel: int

func _ready() -> void: 
	setInteractedCounter(Global.gameState["interactionCounters"]["secretary"])
	Events.connect("tutorial_finished", self, "onTutorialFinished")

	
func onTutorialFinished() -> void:
	Global.gameState["interactionCounters"]["secretary"] = 1
	setInteractedCounter(1)

func sayBranch(branch: Dictionary) -> void:
	.sayBranch(branch)
	if branch.has("love_points"):
		loveLevel += branch["love_points"]
		print("Love level has changed to %s" % loveLevel)
