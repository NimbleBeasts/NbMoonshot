extends Control

var lives = 0

func _ready():
	Events.connect("visible_level_changed", self, "updateLightLevel")
	Events.connect("audio_level_changed", self, "updateAudioLevel")
	Events.connect("player_taser_fired", self, "updateAmmo")
	Events.connect("hud_update_money", self, "updateMoney")
	
	
	Events.connect("player_detected", self, "updateLives")
	Events.connect("allowed_detections_updated", self, "resetLives")


func resetLives(value) -> void:
	lives = value
	$BottomBar/Life.set_text(str(value))

func updateLives(_type) -> void:
	lives -= 1
	$BottomBar/Life.set_text(str(lives))

func updateMoney(total, change) -> void:
	#TODO animate change
	$TopBar/Money.set_text(str(total))
	

func updateAmmo(value) -> void:
	$BottomBar/Ammo.set_text(str(value))


func updateLightLevel(newLightLevel) -> void:
	return
#	match newLightLevel:
#		Types.LightLevels.Dark:
#			$LightIndicator.frame = 2
#		Types.LightLevels.BarelyVisible:
#			$LightIndicator.frame = 1
#		Types.LightLevels.FullLight:
#			$LightIndicator.frame = 0
#		_:
#			print("HUD: Illegal light level provided")

func updateAudioLevel(newAudioLevel, _audio_pos, _emitter) -> void: #TODO: audio_pos needed?
	pass
#	if newAudioLevel >= 0 and newAudioLevel < Types.AudioLevels.size():
#		$AudioIndicator.frame = newAudioLevel
		
