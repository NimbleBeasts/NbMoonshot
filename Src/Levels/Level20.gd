extends "res://Src/Levels/BaseLevel.gd"

var timerStarted = false
var time = 60.0

func _ready():
	#$BombTimer.hide()
	timerStarted = true


func _physics_process(delta):
	if timerStarted:
		time -= delta
		updateTimer()

func updateTimer():
	var timerValue = int(time * 100)
	$BombTimer/Layer/WireTimer/dig6.frame = max(0, timerValue % 10) #least significant digit 
	$BombTimer/Layer/WireTimer/dig5.frame = max(0, (timerValue / 10) % 10)
	$BombTimer/Layer/WireTimer/dig4.frame = max(0, (timerValue / 100) % 10)
	$BombTimer/Layer/WireTimer/dig3.frame = max(0, (timerValue / 1000) % 10)

	

