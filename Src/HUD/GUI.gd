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

func updateLives(type) -> void:
	if type == Types.DetectionLevels.Sure:
		lives -= 1
		$BottomBar/Life.set_text(str(lives))
		

func updateMoney(total, change) -> void:
	#TODO animate change
	$TopBar/Money.set_text(str(total))
	

func updateAmmo(value) -> void:
	$BottomBar/Ammo.set_text(str(value))


func updateLightLevel(newLightLevel) -> void:
	#print(newLightLevel)
	match newLightLevel:
		Types.LightLevels.FullLight:
			$BottomBar/Light.frame = 0
			if not $BottomBar/WarnFrameLight/AnimationPlayer.is_playing():
				$BottomBar/WarnFrameLight/AnimationPlayer.play("flash")
		Types.LightLevels.BarelyVisible:
			$BottomBar/Light.frame = 1
		_:
			$BottomBar/Light.frame = 2

func updateAudioLevel(newAudioLevel, _audio_pos, _emitter) -> void: #TODO: audio_pos needed?
	$BottomBar/Audio/AnimationPlayer.play("sound")
	#TODO: we need to do a proper handling here. however sound does not play such an important role
	return
	
	print("audio:" + str(newAudioLevel))
	if newAudioLevel >= 0 and newAudioLevel < Types.AudioLevels.size():
		$BottomBar/Audio.frame = newAudioLevel
		
