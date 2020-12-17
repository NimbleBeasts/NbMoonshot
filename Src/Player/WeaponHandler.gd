extends Node

var currentIndex: int
onready var currentWeapon = get_child(0)
onready var maxWeaponAmount: int = get_child_count()


func _ready() -> void:
	equipWeapon(0)
	Events.connect("switched_weapon", self, "equipWeapon")


func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	if event.is_action_pressed("selection"):
		if not currentIndex >= maxWeaponAmount - 1:
			currentIndex += 1
		else:
			currentIndex = 0
		
		Events.emit_signal("switched_weapon", currentIndex)


func equipWeapon(weaponIndex: int) -> void:
	print(get_child(weaponIndex).name + " equipped")
	var newWeapon = get_child(weaponIndex)
	currentWeapon.set_process(false)
	newWeapon.set_process(true)
	currentWeapon = newWeapon
