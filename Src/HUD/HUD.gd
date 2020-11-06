extends CanvasLayer

enum HoverType {Light, Audio, Web}


func _ready():
	Events.connect("light_level_changed", self, "updateLightLevel")
	Events.connect("audio_level_changed", self, "updateAudioLevel")
	

func updateLightLevel(newLightLevel):
	match newLightLevel:
		Types.LightLevels.Dark:
			$LightIndicator.frame = 2
		Types.LightLevels.BarelyVisible:
			$LightIndicator.frame = 1
		Types.LightLevels.FullLight:
			$LightIndicator.frame = 0
		_:
			print("HUD: Illegal light level provided")
	

func updateAudioLevel(newAudioLevel, audio_pos):
	if newAudioLevel >= 0 and newAudioLevel < Types.AudioLevels.size():
		$AudioIndicator.frame = newAudioLevel
	else:
		print("HUD: Illegal audio level provided")
	
	$AudioIndicator/GoBackToNormal.start()


func _on_GoBackToNormal_timeout() -> void:
	$AudioIndicator.frame = 2


func hover(type):
	match type:
		HoverType.Web:
			$Hovers/Indicator.position = Vector2(12, 0)
			$Hovers/Label.set_text("Status: Web Monetization Plugin.")
		HoverType.Audio:
			$Hovers/Indicator.position = Vector2(43, 0)
			$Hovers/Label.set_text("This is your noise indicator.")
		_: #Light
			$Hovers/Indicator.position = Vector2(72, 0)
			$Hovers/Label.set_text("This is your visibilty indicator.")
	$Hovers.show()



func _on_LightHover_mouse_entered():
	hover(HoverType.Light)


func _on_LightHover_mouse_exited():
	$Hovers.hide()


func _on_AudioHover_mouse_entered():
	hover(HoverType.Audio)


func _on_AudioHover_mouse_exited():
	$Hovers.hide()


func _on_WebHover_mouse_entered():
	hover(HoverType.Web)


func _on_WebHover_mouse_exited():
	$Hovers.hide()

