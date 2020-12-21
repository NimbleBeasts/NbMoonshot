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

onready var animPlayer: AnimationPlayer = $AnimationPlayer

#if carry body & E: open, throw body in, close
#if not carry body & E: open
#if not cary body & E & open: go in and close

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

	if hiddenGuard != null:
		get_tree().set_input_as_handled()
		hiddenGuard.show()
		player.guardPickup.guard = hiddenGuard
		player.guardPickup.dragGuard()
		hiddenGuard = null
		return

	if player.guardPickup.isDraggingGuard:
		hideGuard()
		return

	destroyGuard = false
	if isOpen:
		hidePlayer()
	else:
		openCloset()


func hideGuard() -> void:
	Events.emit_signal("set_player_state", Types.PlayerStates.Normal)
	Events.emit_signal("hud_game_hint", "Hidden guard.")
	guard = player.guardPickup.guard
	player.guardPickup.guard = null
	guard.global_position = getPoint()
	player.guardPickup.stopDragging()
	destroyGuard = true
	$AnimationPlayer.play("open")


func hidePlayer() -> void:
	$Sprite.z_index = player.z_index + 1
	$AnimationPlayer.play("close")
	Events.emit_signal("block_player_movement")
	goInCloset = true
	isOpen = false


func openCloset() -> void:
	$Sprite.z_index = player.z_index - 1
	goInCloset = false
	$AnimationPlayer.play("open")
	if player.state == Types.PlayerStates.InCloset:
		player.set_state(Types.PlayerStates.Normal)
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
		if destroyGuard:
			guard.hide()
			hiddenGuard = guard
			animPlayer.play("close")
	elif anim_name == "close":
		if goInCloset:
			Events.emit_signal("set_player_state", Types.PlayerStates.InCloset)
			player.global_position = getPoint()
