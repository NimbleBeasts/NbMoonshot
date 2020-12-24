extends Area2D

var pressureObjects = []
export (Array, NodePath) var unlocks: Array


func _ready() -> void:
	connect("area_entered", self, "onAreaEntered")
	connect("area_exited", self, "onAreaExited")

		
func onAreaEntered(area: Area2D) -> void:
	# don't need to put a check whether it collided with a pressure node or not 
	# because this areas collision mask only allows it to collide with 'Pressure' objects
	if pressureObjects == []:
		pressureObjects.append(area.mainNode)
		press()


func onAreaExited(area: Area2D) -> void:
	if pressureObjects.has(area.mainNode):
		pressureObjects.erase(area.mainNode)
		if pressureObjects == []:
			press()


func press() -> void:
	for nodepath in unlocks:
		var node = get_node(nodepath)
		if node is Lights:
			node.toggleState()
		elif node is DoorWall:
			if node.lockLevel == node.DoorLockType.buttonLocked:
				node.open()
				return
			elif node.lockLevel == node.DoorLockType.open:
				node.resetState()
				return
			printerr("Trying to open %s that isn't of locked level 'buttonLocked' through %s" % [node.name, name])
