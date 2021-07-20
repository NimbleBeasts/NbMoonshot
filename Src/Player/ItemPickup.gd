extends Node

var possiblePickup
var currentPickup = null
var processAnims: bool
var hasItemPickup: bool

export var playerPath: NodePath
export var carryPositionPath: NodePath
onready var player = get_node(playerPath)
onready var carryPosition = get_node(carryPositionPath)


func _ready() -> void:
	set_process(false)
	set_process_unhandled_input(false)
	Events.connect("player_item_drop", self, "dropCurrentItem")
	Events.connect("player_item_pickup", self, "pickupItem")


func _process(delta: float) -> void:
	if currentPickup != null:
		currentPickup.global_position = carryPosition.global_position
		if processAnims:
			var correctAnim = "carryIdle" if int(player.velocity.x) == 0 else "carryWalk"
			Events.emit_signal("player_animation_change", correctAnim)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not player.guardPickup.isDragging:
		if currentPickup == null:
			# Picking up
			pickupItem(possiblePickup)
			get_tree().set_input_as_handled()
			return
		# hacky workaround
		for area in player.get_node("PlayerArea").get_overlapping_areas():
			if area is Door:
				return
			if area.is_in_group("HackZone"):
				area.get_parent().hackWithDevice()
				return
			if area.is_in_group("ExtractionZone"):
				return
		dropCurrentItem()
		get_tree().set_input_as_handled()


func onPlayerAreaEntered(area: Area2D) -> void:
	if area is Pickupable:
		possiblePickup = area
		set_process_unhandled_input(true)


func onPlayerAreaExited(area: Area2D) -> void:
	if area == possiblePickup:
		possiblePickup = null
		set_process_unhandled_input(false)

#Instead of dropping remove it from scene completly
func removeCurrentItem() -> void:
	if currentPickup == null:
		return
	if hasItemPickup:
		hasItemPickup = false
		currentPickup.queue_free()
		currentPickup = null
		Events.emit_signal("player_state_set", Types.PlayerStates.Normal)
		Events.emit_signal("player_animation_change", "idle")

func dropCurrentItem(blockInput: bool = true) -> bool:
	if currentPickup == null:
		return false
	if hasItemPickup:
		hasItemPickup = false
		currentPickup.drop()
		processAnims = false
		if blockInput:
			Events.emit_signal("player_block_input")
		else:
			currentPickup.global_position = carryPosition.global_position
			currentPickup = null

		Events.emit_signal("player_animation_change", "laydown")
	return true

func pickupItem(item: Pickupable) -> void:
	currentPickup = item
	hasItemPickup = true
	item.pickup()
	Events.emit_signal("player_state_set", Types.PlayerStates.DraggingItem)
	Events.emit_signal("player_animation_change", "pickup")
	set_process(true)


func onAnimationFinished(animName: String) -> void:
	# making sure animation finished is from this 
	if currentPickup == null:
		return
	if animName == "laydown":
		currentPickup.global_position = carryPosition.global_position
		Events.emit_signal("player_unblock_input")
		Events.emit_signal("player_unblock_movement")
		Events.emit_signal("player_state_set", Types.PlayerStates.Normal)
		currentPickup = null
	elif animName == "pickup":
		processAnims = true
		currentPickup.global_position = carryPosition.global_position

