extends Area2D

export var playerPath: NodePath
export var carryPositionPath: NodePath
var guard: Guard
var isDraggingGuard: bool
var processAnims: bool
onready var player: Player = get_node(playerPath)
onready var carryPosition: Position2D = get_node(carryPositionPath)



func _ready() -> void:
	set_process(false)
	Events.connect("drop_guard", self, "stopDragging")
	connect("body_entered", self, "onBodyEntered")
	connect("body_exited", self, "onBodyExited")


func _process(delta: float) -> void:
	if guard != null and isDraggingGuard:
		guard.global_position = carryPosition.global_position
		if processAnims:
			var correctAnim: String = "carryIdle" if int(player.velocity.x) == 0 else "carryWalk"
			Events.emit_signal("change_player_animation", correctAnim)


func _unhandled_input(event: InputEvent) -> void:
	if guard == null:
		return
	if not isDraggingGuard and player.itemPickup.currentPickup == null:
		if Input.is_action_just_pressed("interact") and guard.state == Types.GuardStates.Stunned and guard.isSleeping:
			dragGuard()
			return
	if guard.state == Types.GuardStates.BeingDragged:
		if event.is_action_pressed("interact"):
			stopDragging()


func onBodyEntered(body: Node) -> void:
	if body.is_in_group("Guard"):
		guard = body
		set_process(true)


func onBodyExited(body: Node) -> void:
	if body == guard:
		guard = null
		set_process(false)


func stopDragging() -> void:
	if guard != null and isDraggingGuard:
		processAnims = false
		guard.state = Types.GuardStates.Stunned
		player.set_state(Types.PlayerStates.Normal)
		Events.emit_signal("block_player_input")
		Events.emit_signal("change_player_animation", "laydown")


func dragGuard() -> void:
	guard.set_state(Types.GuardStates.BeingDragged)
	player.set_state(Types.PlayerStates.DraggingGuard)
	isDraggingGuard = true
	processAnims = false
	Events.emit_signal("block_player_input")
	Events.emit_signal("change_player_animation", "pickup")
	Events.emit_signal("forcefully_close_minigame")


func onAnimationFinished(animName: String) -> void:
	if not isDraggingGuard:
		return
	if animName == "pickup":
		Events.emit_signal("unblock_player_input")
		Events.emit_signal("unblock_player_movement")
		processAnims = true
	elif animName == "laydown":
		Events.emit_signal("unblock_player_input")
		Events.emit_signal("unblock_player_movement")
		isDraggingGuard = false
		processAnims = false
