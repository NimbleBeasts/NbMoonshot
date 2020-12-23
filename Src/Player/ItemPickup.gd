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
			currentPickup = possiblePickup
			currentPickup.pickup()
			Events.emit_signal("hud_game_hint", "Picked up " + str(currentPickup.pickupName))
		# else:
		# 	# Dropping a pickup
		# 	currentPickup = null
		# 	Events.emit_signal("hud_game_hint", "Dropped " + str(currentPickup.pickupName))

	if currentPickup != null:
		currentPickup.global_position = player.global_position + currentPickup.pickupOffset


func onPlayerAreaEntered(area: Area2D) -> void:
	if area is Pickupable:
		possiblePickup = area
		set_process(true)


func onPlayerAreaExited(area: Area2D) -> void:
	if area == possiblePickup:
		possiblePickup = null
		set_process(false)
