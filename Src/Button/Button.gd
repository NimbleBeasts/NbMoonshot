extends Area2D

export (Array, NodePath) var unlocks: Array
var player


func _ready() -> void:
	connect("body_entered", self, "onBodyEntered")
	connect("body_exited", self, "onBodyExited")
	set_process_input(false)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		press()


func onBodyEntered(body: Node) -> void:
	if body.is_in_group("Player"):
		player = body
		set_process_input(true)


func onBodyExited(body: Node) -> void:
	if body.is_in_group("Player"):
		player = null
		set_process_input(false)


func press() -> void:
	Events.emit_signal("hud_game_hint", "Button pressed")
	for thing in unlocks:
		var node = get_node(thing)
		if node is Lights:
			node.toggleState()
		elif node is DoorWall:
			if node.lockLevel == node.DoorLockType.buttonLocked:
				node.open()
				return
			printerr("Trying to open %s through a button that isn't of locked level 'buttonLocked'." % node.name)