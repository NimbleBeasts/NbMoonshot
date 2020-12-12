extends Node

export var maxWeaponAmount: int = 3
var currentIndex: int


func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	if event.is_action_pressed("selection"):
		if not currentIndex >= maxWeaponAmount:
			currentIndex += 1
		else:
			currentIndex = 0
		
		Events.emit_signal("switched_weapon", currentIndex)
