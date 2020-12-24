extends Node

var possiblePickup
var currentPickup

export var playerPath: NodePath
onready var player = get_node(playerPath)


func _ready() -> void:
	set_process(false)
	set_process_unhandled_input(false)
	Events.connect("drop_current_item", self, "dropCurrentItem")
	Events.connect("pickup_item", self, "pickupItem")


func _process(delta: float) -> void:
	if currentPickup != null:
		currentPickup.global_position.x = player.global_position.x + currentPickup.pickupOffset.x


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
	Events.emit_signal("set_player_state", Types.PlayerStates.Normal)
	currentPickup = null
	set_process(false)


func pickupItem(item) -> void:
	currentPickup = item
	item.pickup()
	currentPickup.global_position = player.global_position + currentPickup.pickupOffset
	Events.emit_signal("set_player_state", Types.PlayerStates.DraggingItem)
	set_process(true)
