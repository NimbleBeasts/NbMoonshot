extends Area2D

export (Array, NodePath) var unlocks: Array
var offset: float = 6
var pressureObjects = []


func _ready() -> void:
	connect("area_entered", self, "onAreaEntered")
	connect("area_exited", self, "onAreaExited")


func onAreaEntered(area: Area2D) -> void:
	# don't need to put a check whether it collided with a pressure node or not 
	# because this areas collision mask only allows it to collide with 'Pressure' objects
	# turned on
	if pressureObjects == []:
		$Sprite.frame = 1
		press()

	pressureObjects.append(area.mainNode)

	
func onAreaExited(area: Area2D) -> void:
	if pressureObjects.has(area.mainNode):
		# turned off
		pressureObjects.erase(area.mainNode)
		if pressureObjects == []:
			$Sprite.frame = 0
			press()

			
func press() -> void:
	for nodepath in unlocks:
		var node = get_node(nodepath)
		if node is Lights:
			node.toggleState()
		elif node is DoorWall:
			if node.lockLevel == Types.DoorLockType.buttonLocked:
				node.open()
				node.interact(false, global_position)
				return
			elif node.lockLevel == Types.DoorLockType.open:
				node.interact(false, global_position)
				node.resetState()
				return
			printerr("Trying to open %s that isn't of locked level 'buttonLocked' through %s" % [node.name, name])
