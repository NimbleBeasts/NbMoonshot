tool
extends HideOutBase

# Naming this Types would cause it to clashe with the singleton Types
enum ClosetTypes {Wooden, Metal}

var type = ClosetTypes.Wooden

var isOpen: bool
var destroyGuard: bool
var guard
var goInCloset: bool

onready var animPlayer: AnimationPlayer = $AnimationPlayer

#if carry body & E: open, throw body in, close
#if not carry body & E: open
#if not cary body & E & open: go in and close

func _ready():
	animPlayer.connect("animation_finished", self, "onAnimationFinished")
	if type == ClosetTypes.Wooden:
		$Sprite.texture = preload("res://Assets/HideOuts/WoodCloset.png")
		$Bg.texture = preload("res://Assets/HideOuts/WoodClosetBg.png")
	else:
		$Sprite.texture = preload("res://Assets/HideOuts/MetalCloset.png")
		$Bg.texture = preload("res://Assets/HideOuts/MetalClosetBg.png")


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or not player:
		return

	if player.guardPickup.isDraggingGuard:
		print("hide guard")
		guard = player.guardPickup.guard
		destroyGuard = true
		$AnimationPlayer.play("open")
		return

	destroyGuard = false
	if isOpen and playerInArea:
		print("go in and close")
		$AnimationPlayer.play("close")
		Events.emit_signal("block_player_movement")
		goInCloset = true
		isOpen = false
	else:
		goInCloset = false
		$AnimationPlayer.play("open")
		if player.state == Types.PlayerStates.InCloset:
			player.set_state(Types.PlayerStates.Normal)
		print("open closet")
		isOpen = true


func onAnimationFinished(animName: String) -> void:
	if animName == "open":
		if destroyGuard:
			guard.queue_free()
		animPlayer.play("close")
	elif animName == "close":
		if goInCloset:
			player.set_state(Types.PlayerStates.InCloset)
