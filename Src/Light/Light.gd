tool
extends Node2D
class_name Lights

export(bool) var flicker = false
export(String) var flickerSequence = "1110"

export(bool) var DebugLight = false
export(Color, RGBA) var col1 = Color(1,0.1,1,1)
export(Color, RGBA) var col2 = Color(0.2,0.2,1,1)

enum LightState {On = 1, Off = 0}

var state = LightState.On
var currentIndex = 0
var isActive: bool = true


func _draw():
	if DebugLight:
		var poly = $BarelyVisible/Left.polygon
		draw_line(poly[0], poly[1], col1)
		draw_line(poly[1], poly[2], col1)
		draw_line(poly[2], poly[0], col1)
		
		poly = $BarelyVisible/Right.polygon
		draw_line(poly[0], poly[1], col1)
		draw_line(poly[1], poly[2], col1)
		draw_line(poly[2], poly[0], col1)

		poly = $FullLight/CollisionPolygon2D.polygon
		draw_line(poly[0], poly[1], col2)
		draw_line(poly[1], poly[2], col2)
		draw_line(poly[2], poly[3], col2)
		draw_line(poly[3], poly[0], col2)


func _ready():
	if flicker:
		updateLight() # Perform first state directly 
		$Timer.start()


func isOn():
	if state == LightState.On and isActive:
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
			$Light2D.enabled = true
		else:
			$Light2D.hide()
			$Light2D.enabled = false


func toggleState() -> void:
	if isActive:
		deactivate()
	else:
		activate()


func _on_Timer_timeout():
	updateLight()


func deactivate() -> void:
	$Light2D.hide()
	$Light2D.enabled = false
	$FullLight.set_deferred("monitoring", false)
	$BarelyVisible.set_deferred("monitoring", false)
	$Timer.stop()
	isActive = false


func activate() -> void:
	$Light2D.show()
	$Light2D.enabled = true
	$FullLight.set_deferred("monitoring", true)
	$BarelyVisible.set_deferred("monitoring", true)
	if flicker:
		$Timer.start()
	isActive = true
