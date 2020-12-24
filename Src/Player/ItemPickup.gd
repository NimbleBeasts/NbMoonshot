extends Node

var possiblePickup
var currentPickup
var processAnims: bool

export var playerPath: NodePath
export var carryPositionPath: NodePath
onready var player = get_node(playerPath)
onready var carryPosition = get_node(carryPositionPath)


func _ready() -> void:
	set_process(false)
	set_process_unhandled_input(false)
	Events.connect("drop_current_item", self, "dropCurrentItem")
	Events.connect("pickup_item", self, "pickupItem")


func _process(delta: float) -> void:
	if currentPickup != null:
		currentPickup.global_position = carryPosition.global_position
		if processAnims:
			if int(player.velocity.x) != 0:
				Events.emit_signal("change_player_animation", "carryWalk")
			else:
				Events.emit_signal("change_player_animation", "carryIdle")
		

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if currentPickup == null:
			# Picking up
			pickupItem(possiblePickup)
			return
		dropCurrentItem()


func onPlayerAreaEntered(area: Area2D) -> void:
	if area is Pickupable:
		possiblePickup = area
		set_process_unhandled_input(true)


func onPlayerAreaExited(area: Area2D) -> void:
	if area == possiblePickup:
		possiblePickup = null
		set_process_unhandled_input(false)


func dropCurrentItem() -> void:
	if currentPickup == null:
		return
	currentPickup.drop()
	processAnims = false
	Events.emit_signal("block_player_input")
	Events.emit_signal("change_player_animation", "laydown")


func pickupItem(item: Pickupable) -> void:
	currentPickup = item
	item.pickup()
	Events.emit_signal("set_player_state", Types.PlayerStates.DraggingItem)
	Events.emit_signal("change_player_animation", "pickup")
	set_process(true)


func onAnimationFinished(animName: String) -> void:
	if animName == "laydown":
		currentPickup.global_position = carryPosition.global_position
		Events.emit_signal("unblock_player_input")
		Events.emit_signal("unblock_player_movement")
		Events.emit_signal("set_player_state", Types.PlayerStates.Normal)
		currentPickup = null
	elif animName == "pickup":
		processAnims = true
		currentPickup.global_position = carryPosition.global_position

