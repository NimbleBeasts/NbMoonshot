tool
extends Node2D

export(bool) var flicker = false
export(String) var flickerSequence = "1110"

enum LightState {On = 1, Off = 0}

var state = LightState.On
var currentIndex = 0


func _ready():
	if flicker:
		$Timer.start()


func isOn():
	if state == LightState.On:
		return true
	return false


func updateLight():
	currentIndex += 1
	
	if currentIndex >= flickerSequence.length():
		currentIndex = 0
	
	var desiredFrameState = int(flickerSequence[currentIndex])
	if desiredFrameState != state:
		state = desiredFrameState
		if state == LightState.On:
			$Light2D.show()
		else:
			$Light2D.hide()


func _on_Timer_timeout():
	updateLight()


func deactivate() -> void:
	$Light2D.hide()
	$FullLight.set_deferred("monitoring", false)
	$BarelyVisible.set_deferred("monitoring", false)
	$Timer.stop()
