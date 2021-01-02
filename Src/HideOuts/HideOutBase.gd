class_name HideOutBase
extends Node2D

export(bool) var canHidePlayer = true
export(bool) var canBeOpened = true

var player: Player
var playerInArea: bool

var isOpen: bool
var destroyGuard: bool
var guard
var goInCloset: bool
var hiddenGuard
var unhidingGuard: bool

var playerLastPickup

onready var animPlayer: AnimationPlayer = $AnimationPlayer


func _ready():
	set_process_input(false)
	$Area2D.connect("body_entered", self, "_on_Area2D_body_entered")
	$Area2D.connect("body_exited", self, "_on_Area2D_body_exited")
	if not canBeOpened:
		$Area2D.queue_free()


func getPoint():
	return $Position2D.global_position


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return

	get_tree().set_input_as_handled()

	if player.state == Types.PlayerStates.DraggingItem:
		playerLastPickup = player.itemPickup.currentPickup
		Events.emit_signal("drop_current_item")
		Events.emit_signal("set_player_state", Types.PlayerStates.Normal)

	# unhiding guard if hidden and press E
	if hiddenGuard != null:
		unhidingGuard = true
		animPlayer.play("open")
		Events.emit_signal("block_player_movement")
		$Sprite.z_index = player.z_index - 1
		return

	if player.guardPickup.isDragging:
		if not isOpen:
			playerLastPickup = null
			openCloset()
		hideGuard()
		return

	destroyGuard = false
	if isOpen:
		hidePlayer()
	else:
		openCloset()


func hideGuard() -> void:
	playerLastPickup = null
	$Sprite.z_index = player.z_index - 1
	Events.emit_signal("set_player_state", Types.PlayerStates.Normal)
	guard = player.guardPickup.object
	player.guardPickup.object = null
	if guard == null:
		return
	guard.global_position = getPoint()
	player.guardPickup.stopDragging()
	destroyGuard = true
	animPlayer.play_backwards("open")
	goInCloset = false


func hidePlayer() -> void:
	$Sprite.z_index = player.z_index + 1
	animPlayer.play("close")
	Events.emit_signal("block_player_input")
	goInCloset = true
	isOpen = false


func openCloset() -> void:
	$Sprite.z_index = player.z_index - 1
	goInCloset = false
	animPlayer.play("open")
	if player.state == Types.PlayerStates.InCloset:
		player.set_state(Types.PlayerStates.Normal)
		if playerLastPickup != null:
			Events.emit_signal("pickup_item", playerLastPickup)
	isOpen = true


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		playerInArea = true
		set_process_input(true)


func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		playerInArea = false
		if not goInCloset:
			set_process_input(false)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "open":
		if unhidingGuard:
			unhidingGuard = false
			player.guardPickup.object = hiddenGuard
			player.guardPickup.dragObject()
			hiddenGuard.show()
			hiddenGuard = null
			goInCloset = false
			Events.emit_signal("unblock_player_movement")
			return
		if destroyGuard:
			guard.hide()
			hiddenGuard = guard

		# making sure input and movement is not blocked
		if player.movementBlocked:
			Events.emit_signal("unblock_player_movement")
		if player.blockEntireInput:
			Events.emit_signal("unblock_player_input")

	elif anim_name == "close":
		if goInCloset:
			Events.emit_signal("set_player_state", Types.PlayerStates.InCloset)
			player.global_position = getPoint()
