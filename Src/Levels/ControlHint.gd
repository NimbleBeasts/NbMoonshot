extends Sprite


func _ready() -> void:
	visible = true if Global.gameState.interactionCounters.boss == 0 else false
	Events.connect("tutorial_finished", self, "onTutorialFinished")


func onTutorialFinished() -> void:
	hide()
