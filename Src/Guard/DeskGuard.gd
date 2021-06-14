tool
extends Node2D

enum LookDirectionType {Left, Right}
enum GuardState {Reading, Looking, Hidden}

export(LookDirectionType) var lookDirection = LookDirectionType.Left
export(float) var lookDuration = 2
export(float) var readDuration = 3
export var removeNotifierDuration: float = 1

onready var style = get_parent().level_nation_type #Types.LevelTypes

var guardState = GuardState.Reading
var player = null

func _ready():
	#Load sprite
	if (style == Types.LevelTypes.USA):
		$Sprite.texture = preload("res://Assets/Guards/DeskGuard_Blue.png")
	else:
		$Sprite.texture = preload("res://Assets/Guards/DeskGuard_Green.png")

	$LookTimer.wait_time = lookDuration
	$ReadTimer.wait_time = readDuration
	$RemoveNotifierTimer.wait_time = removeNotifierDuration
	$RemoveNotifierTimer.connect("timeout", self, "onRemoveNotifierTimeout")

	if lookDirection == LookDirectionType.Left:
		$Flipable.scale.x = -1
	
	switchState(GuardState.Reading)
	set_process(false)


func _process(_delta):
	if guardState == GuardState.Looking:
		if player:
			if player.visible_level == Types.LightLevels.FullLight:
				if $DelayTimer.time_left == 0:
					# Detected!
					$DelayTimer.start()
					player = null


func switchState(to):
	match to:
		GuardState.Reading:
			$Sprite.frame = 1 
			switchFOV(false)
			$ReadTimer.start()
		GuardState.Looking:
			if lookDirection == LookDirectionType.Left:
				$Sprite.frame = 2 
			else:
				$Sprite.frame = 0
			switchFOV(true)
			$LookTimer.start()
		GuardState.Hidden:
			$AnimationPlayer.play("hide")
			switchFOV(false)
		_:
			print("Never should get here")
	guardState = to

func switchFOV(on):
	if on:
		$Flipable/FOV.monitoring = true
	else:
		$Flipable/FOV.monitoring = false
		player = null


func _on_FOV_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		set_process(true)


func _on_FOV_body_exited(body):
	if body.is_in_group("Player"):
		player = null
		set_process(false)


func _on_LookTimer_timeout():
	switchState(GuardState.Reading)


func _on_ReadTimer_timeout():
	switchState(GuardState.Looking)


func _on_DelayTimer_timeout():
	$Notifier.popup(Types.NotifierTypes.Exclamation)
	$LookTimer.stop()
	$ReadTimer.stop()
	switchState(GuardState.Hidden)
	Events.emit_signal("player_detected", Types.DetectionLevels.Sure)
	$DeskGuardDetect.play()
	$RemoveNotifierTimer.start()

func onRemoveNotifierTimeout() -> void:
	$Notifier.remove()


func _on_AudioListener_invoked(type, pos):
	$Notifier.popup(Types.NotifierTypes.Question)
	$LookTimer.stop()
	$ReadTimer.stop()
	$RemoveNotifierTimer.start()
	
	var noiseDirection = LookDirectionType.Right
	if pos.x < self.global_position.x:
		#Left
		noiseDirection = LookDirectionType.Left

	if noiseDirection == LookDirectionType.Left:
		$Flipable.scale.x = -1
		$Sprite.frame = 2 
	else:
		$Flipable.scale.x = 1
		$Sprite.frame = 0
	$ConfusionTimer.start()

func _on_ConfusionTimer_timeout():
	switchState(GuardState.Reading)
	if lookDirection == LookDirectionType.Left:
		$Flipable.scale.x = -1
	else:
		$Flipable.scale.x = 1
