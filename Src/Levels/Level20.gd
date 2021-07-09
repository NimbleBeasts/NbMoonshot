extends "res://Src/Levels/BaseLevel.gd"

var timerStarted = false
var time = 60.0

func _ready():
	$AdditionalHUD/BombTimer.hide()
	$NPCS/Secretary.connect("npc_dialogue_finished", self, "dialogue_finished")


# Intro functions
func dialogue_finished():
	$DialogueBlocker.position = Vector2(-100,-100)
	$NPCS/Secretary/WalkAnimationPlayer.play("walk")
	Events.emit_signal("player_block_movement")

func _on_WalkAnimationPlayer_animation_finished(anim_name):
	Events.emit_signal("player_unblock_movement")
	$AdditionalHUD/BombTimer.show()
	timerStarted = true



func _physics_process(delta):
	if timerStarted:
		time -= delta
		updateTimer()

func updateTimer():
	var timerValue = int(time * 100)
	$AdditionalHUD/BombTimer/WireTimer/dig6.frame = max(0, timerValue % 10) #least significant digit 
	$AdditionalHUD/BombTimer/WireTimer/dig5.frame = max(0, (timerValue / 10) % 10)
	$AdditionalHUD/BombTimer/WireTimer/dig4.frame = max(0, (timerValue / 100) % 10)
	$AdditionalHUD/BombTimer/WireTimer/dig3.frame = max(0, (timerValue / 1000) % 10)

	

