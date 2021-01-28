extends Sprite


func _ready() -> void:
	hide()
	Events.connect("player_selection_held", self, "onCameraHeldSelection")
	Events.connect("player_selection_released", self, "onCameraReleasedSelection")


func onCameraHeldSelection() -> void:
	show()


func onCameraReleasedSelection() -> void:
	hide()
