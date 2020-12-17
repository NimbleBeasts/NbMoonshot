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
	var oldWeapon = currentWeapon
	var newWeapon = get_child(weaponIndex)
	oldWeapon.set_process(false)
	oldWeapon.set_physics_process(false)
	newWeapon.set_physics_process(true)
	newWeapon.set_process(true)
	currentWeapon = newWeapon
	Events.emit_signal("hud_game_hint", "Switched from %s to %s" % [oldWeapon.name, newWeapon.name])
