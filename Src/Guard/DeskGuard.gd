tool
extends Node2D

enum LookDirectionType {Left, Right}
enum GuardState {Reading, Looking, Hidden}

export(LookDirectionType) var lookDirection = LookDirectionType.Left
export(float) var lookDuration = 2
export(float) var readDuration = 3
export var removeNotifierDuration: float = 1

onready var style = get_parent().level_type #Types.LevelTypes

var guardState = GuardState.Reading
var player = null

func _ready():
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
			$Sprite.frame = 1 if (style == Types.LevelTypes.Western) else 5
			switchFOV(false)
			$ReadTimer.start()
		GuardState.Looking:
			if lookDirection == LookDirectionType.Left:
				$Sprite.frame = 2 if (style == Types.LevelTypes.Western) else 6
			else:
				$Sprite.frame = 0 if (style == Types.LevelTypes.Western) else 4
			switchFOV(true)
			$LookTimer.start()
		GuardState.Hidden:
			if (style == Types.LevelTypes.Western):
				$AnimationPlayer.play("hide_blue")
			else:
				$AnimationPlayer.play("hide_green")
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
	Events.emit_signal("play_sound", "deskguard_detect")
	$RemoveNotifierTimer.start()

func onRemoveNotifierTimeout() -> void:
	$Notifier.remove()
