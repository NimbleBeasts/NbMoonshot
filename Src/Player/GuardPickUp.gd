extends Area2D

export var playerPath: NodePath
export var carryPositionPath: NodePath
var possibleObject
var object
var isDragging: bool
var processAnims: bool
onready var player: Player = get_node(playerPath)
onready var carryPosition: Position2D = get_node(carryPositionPath)


func _ready() -> void:
	set_process(false)
	Events.connect("drop_guard", self, "stopDragging")
	connect("body_entered", self, "onBodyEntered")
	connect("body_exited", self, "onBodyExited")


func _process(delta: float) -> void:
	if object != null and isDragging:
		object.global_position = carryPosition.global_position
		if processAnims:
			var correctAnim: String = "carryIdle" if int(player.velocity.x) == 0 else "carryWalk"
			Events.emit_signal("change_player_animation", correctAnim)


func _unhandled_input(event: InputEvent) -> void:
	if possibleObject == null:
		return
	if event.is_action_pressed("interact"):
		object = possibleObject
		if object.isBeingDragged():
			stopDragging()
			return
		if not isDragging and player.itemPickup.currentPickup == null and object.canDrag():
			dragPossibleObject()
			

func onBodyEntered(body: Node) -> void:
	if body.is_in_group("Draggable"):
		possibleObject = body
		set_process(true)


func onBodyExited(body: Node) -> void:
	if body == possibleObject:
		possibleObject = null
		set_process(false)


func stopDragging() -> void:
	if object != null and isDragging:
		processAnims = false
		object.stopBeingDragged()
		player.set_state(Types.PlayerStates.Normal)
		Events.emit_signal("block_player_input")
		Events.emit_signal("change_player_animation", "laydown")


func dragPossibleObject() -> void:
	object.drag()
	player.set_state(Types.PlayerStates.DraggingGuard)
	isDragging = true
	processAnims = false
	Events.emit_signal("block_player_input")
	Events.emit_signal("change_player_animation", "pickup")
	Events.emit_signal("forcefully_close_minigame")


func onAnimationFinished(animName: String) -> void:
	if not isDragging:
		return
	if animName == "pickup":
		Events.emit_signal("unblock_player_input")
		Events.emit_signal("unblock_player_movement")
		processAnims = true
	elif animName == "laydown":
		Events.emit_signal("unblock_player_input")
		Events.emit_signal("unblock_player_movement")
		isDragging = false
		processAnims = false
