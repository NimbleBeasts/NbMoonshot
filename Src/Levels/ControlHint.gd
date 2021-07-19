extends Sprite

#TODO bring it back?
func _ready() -> void:
	visible = true if Global.gameState.level.id <= 0 else false
	Events.connect("tutorial_finished", self, "onTutorialFinished")


func onTutorialFinished() -> void:
	hide()
