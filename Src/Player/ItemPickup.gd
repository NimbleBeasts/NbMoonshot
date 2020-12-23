extends Node

var possiblePickup
var currentPickup

export var playerPath: NodePath
onready var player = get_node(playerPath)


func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		if currentPickup == null:
			# Picking up
			currentPickup = possiblePickup
			currentPickup.pickup()
			Events.emit_signal("set_player_state", Types.PlayerStates.DraggingItem)
			return

	if currentPickup != null:
		currentPickup.global_position = player.global_position + currentPickup.pickupOffset
		if Input.is_action_just_pressed("interact"):
			# Dropping a pickup
			currentPickup.drop()
			Events.emit_signal("set_player_state", Types.PlayerStates.Normal)
			currentPickup = null


func onPlayerAreaEntered(area: Area2D) -> void:
	if area is Pickupable:
		possiblePickup = area
		set_process(true)


func onPlayerAreaExited(area: Area2D) -> void:
	if area == possiblePickup:
		possiblePickup = null
		set_process(false)


func dropCurrentItem() -> void:
	if currentPickup == null:
		return
	currentPickup.drop()
	currentPickup = null
