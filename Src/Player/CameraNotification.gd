extends Sprite


func _ready() -> void:
	hide()
	Events.connect("held_selection", self, "onCameraHeldSelection")
	Events.connect("released_held_selection", self, "onCameraReleasedSelection")


func onCameraHeldSelection() -> void:
	show()


func onCameraReleasedSelection() -> void:
	hide()
