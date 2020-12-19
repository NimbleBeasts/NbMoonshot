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

onready var animPlayer: AnimationPlayer = $AnimationPlayer

#if carry body & E: open, throw body in, close
#if not carry body & E: open
#if not cary body & E & open: go in and close

func _ready():
	$Area2D.connect("body_entered", self, "_on_Area2D_body_entered")
	$Area2D.connect("body_exited", self, "_on_Area2D_body_exited")
	if not canBeOpened:
		$Area2D.queue_free()


func getPoint():
	return $Position2D.global_position


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return

	if not playerInArea and not goInCloset:
		return

	if player.guardPickup.isDraggingGuard:
		print("hide guard")
		guard = player.guardPickup.guard
		destroyGuard = true
		$AnimationPlayer.play("open")
		return

	destroyGuard = false
	if isOpen:
		print("go in and close")
		$Sprite.z_index = player.z_index + 1
		$AnimationPlayer.play("close")
		Events.emit_signal("block_player_movement")
		goInCloset = true
		isOpen = false
	else:
		$Sprite.z_index = player.z_index - 1
		goInCloset = false
		$AnimationPlayer.play("open")
		if player.state == Types.PlayerStates.InCloset:
			player.set_state(Types.PlayerStates.Normal)
		print("open closet")
		isOpen = true


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		playerInArea = true


func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		playerInArea = false


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "open":
		if destroyGuard:
			guard.queue_free()
			animPlayer.play("close")
	elif anim_name == "close":
		if goInCloset:
			player.set_state(Types.PlayerStates.InCloset)

