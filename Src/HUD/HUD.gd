extends CanvasLayer



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

func updateAudioLevel(newAudioLevel):
	if newAudioLevel >= 0 and newAudioLevel < Types.AudioLevels.size():
		$AudioIndicator.frame = newAudioLevel
	else:
		print("HUD: Illegal audio level provided")
