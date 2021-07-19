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
	set_process_unhandled_input(false)
	Events.connect("player_guard_drop", self, "stopDragging")
	connect("body_entered", self, "onBodyEntered")
	connect("body_exited", self, "onBodyExited")


func _process(delta: float) -> void:
	if object != null and isDragging:
		var playerCurrentAnim =  player.animPlayer.current_animation
		var offset: Vector2 = Vector2(0, 4) if playerCurrentAnim ==  "carryIdle" or playerCurrentAnim == "carryWalk" else Vector2(0,0)
		object.global_position = carryPosition.global_position + offset 
		
		if player.direction.x != 0:
			object.flip(player.direction.x)

		if processAnims:
			var correctAnim: String = "carryIdle" if int(player.velocity.x) == 0 else "carryWalk"
			Events.emit_signal("player_animation_change", correctAnim)


func _unhandled_input(event: InputEvent) -> void:
	if possibleObject == null:
		return
	if player.currentInteractable != null:
		return
	if event.is_action_pressed("interact"):
		if isDragging and not player.applyGravity:
			for area in player.get_node("PlayerArea").get_overlapping_areas():
				if area.is_in_group("ExtractionZone"):
					return
			stopDragging()
			return
		object = possibleObject
		if player.itemPickup.currentPickup == null and object.canDrag() and not player.blockEntireInput:
			dragObject()
			get_tree().set_input_as_handled()


func stopDragging() -> void:
	if object != null and isDragging:
		processAnims = false
		object.stopBeingDragged()
		player.set_state(Types.PlayerStates.Normal)
		Events.emit_signal("player_block_input")
		Events.emit_signal("player_animation_change", "laydown")
		get_parent().get_node("PlayerSounds/BodyFall").play()


func dragObject() -> void:
	object.drag()
	player.set_state(Types.PlayerStates.DraggingGuard)
	isDragging = true
	processAnims = false
	Events.emit_signal("player_block_input")
	get_parent().get_node("PlayerSounds/BodyPickup").play()
	Events.emit_signal("player_animation_change", "pickup")
	Events.emit_signal("minigame_forcefully_close")
	set_process(true)


func onAnimationFinished(animName: String) -> void:
	if not isDragging:
		return
	if animName == "pickup":
		Events.emit_signal("player_unblock_input")
		Events.emit_signal("player_unblock_movement")
		processAnims = true
	elif animName == "laydown":
		Events.emit_signal("player_unblock_input")
		Events.emit_signal("player_unblock_movement")
		isDragging = false
		processAnims = false
		set_process(false)


func onBodyEntered(body: Node) -> void:
	if body.is_in_group("Draggable"):
		possibleObject = body
		set_process_unhandled_input(true)


func onBodyExited(body: Node) -> void:
	if body == possibleObject and not isDragging:
		possibleObject = null
		set_process_unhandled_input(false)

