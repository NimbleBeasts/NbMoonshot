extends Control

var lives = 0
var time = 0

onready var time1 = $TopBar/Time1
onready var time2 = $TopBar/Time2



func _ready():
	set_process(false)
	Events.connect("visible_level_changed", self, "updateLightLevel")
	Events.connect("audio_level_changed", self, "updateAudioLevel")
	Events.connect("player_taser_fired", self, "updateAmmo")
	Events.connect("hud_update_money", self, "updateMoney")
	Events.connect("hud_mission_briefing_exited", self, "set_process", [true])
	
	Events.connect("player_detected", self, "updateLives")
	Events.connect("allowed_detections_updated", self, "resetLives")


func resetLives(value) -> void:
	lives = value
	$BottomBar/Life.set_text(str(value))
	Global.lives = lives


func _process(delta: float) -> void:
	time += delta

	var milliseconds := int(fmod(time, 1) * 1000)
	var seconds = int(fmod(time, 60))
	var minutes = int(fmod(time, 3600) / 60)
	var milliseconds_string := str(milliseconds)

	if milliseconds_string.length() == 1:
		milliseconds_string = "00%s" % milliseconds_string
	elif milliseconds_string.length() == 2:
		milliseconds_string = "0%s" % milliseconds_string

	var seconds_string = str(seconds)
	seconds_string = "0" + seconds_string if seconds_string.length() == 1 else seconds_string

	var minutes_string = str(minutes)
	minutes_string = "0" + minutes_string if minutes_string.length() == 1 else minutes_string

	time1.text = minutes_string + ":" + seconds_string
	time2.text = ":" + milliseconds_string
	

func updateLives(type) -> void:
	if type == Types.DetectionLevels.Sure:
		lives -= 1
		$BottomBar/Life.set_text(str(lives))

		Global.lives = lives
		$BottomBar/Life/AnimationPlayer.play("flash")
		

func updateMoney(total, change) -> void:
	#TODO animate change
	$TopBar/Money.set_text(str(total))
	

func updateAmmo(value) -> void:
	$BottomBar/Ammo.set_text(str(value))
	$BottomBar/Ammo/AnimationPlayer.play("flash")


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
	pass
	if newAudioLevel >= 0 and newAudioLevel < Types.AudioLevels.size():
		$BottomBar/Audio.frame = newAudioLevel
		
