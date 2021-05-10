extends Node2D

var toBeRemoved = false
var isShowing = false

func _ready():
	$Sprite.scale = Vector2(0.01, 0.01)
	$Sprite.hide()
	$PopupTimer.connect("timeout", self, "remove")
	$PopupTimer.one_shot = true	

func popup(type):
	show()
	toBeRemoved = false
	if type == Types.NotifierTypes.Exclamation:
		$Sprite.frame = 1
	else:
		$Sprite.frame = 0
	
	$Sprite.show()
	$AnimationPlayer.play("popup")
	$Notifier.play()
	isShowing = true


func remove():
	if isShowing:
		toBeRemoved = true
		isShowing = false
		$AnimationPlayer.play_backwards("popup")


func _on_AnimationPlayer_animation_finished(_anim_name):
	if toBeRemoved:
		hide()

func popupForTime(notifierType: int, time: float):
	popup(notifierType)
	$PopupTimer.start(time)
