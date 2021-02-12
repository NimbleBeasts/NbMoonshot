extends Node2D

export (Array, AudioStream) var guardAlarmSounds
export (Array, AudioStream) var guardSuspiciousSounds
export (Array, AudioStream) var playerFootstepSounds
export (Array, AudioStream) var playerCrouchWalkSounds
export (Array, AudioStream) var dogBarkSounds

export (AudioStream) var westernMusic
export (AudioStream) var easternMusic
export (AudioStream) var hqIntro
export (AudioStream) var hqMusic
export (AudioStream) var menuIntro
export (AudioStream) var menuMusic

onready var musicPlayer: AudioStreamPlayer = $Music
onready var music_bus = AudioServer.get_bus_index("Music")
onready var sounds_bus = AudioServer.get_bus_index("Sound")

func _ready():
	# Initial Set Volumes
	setMusicVolume(Global.userConfig.musicVolume)
	setSoundVolume(Global.userConfig.soundVolume)
	
	# Event Hooks
	Events.connect_signal("play_sound", self, "_playSound")
	Events.connect("play_music", self, "onPlayMusic")
	Events.connect("game_over", self, "onGameOver")
	
	Events.connect("cfg_music_set_volume", self, "setMusicVolume")
	Events.connect("cfg_sound_set_volume", self, "setSoundVolume")



###############################################################################
# Callbacks
###############################################################################

func setMusicVolume(value):
	if value == 0:
		$Music.stop()
	else:
		$Music.play()
	AudioServer.set_bus_volume_db(music_bus, linear2db(float(value)/10))

func setSoundVolume(value):
	AudioServer.set_bus_volume_db(sounds_bus, linear2db(float(value)/10))
	

# Event Hook: Play a sound
func _playSound(sound: String, _volume : float = 1.0, _pos : Vector2 = Vector2(0, 0)):
	if Global.userConfig.soundVolume > 0:
		match sound:				# should have made these enums instead, huh
			"menu_click":
				$MenuClick.play()
			"example":
				$Example2D.volume_db = -20 + 12 * _volume
				$Example2D.position = _pos
				$Example2D.play()
			"jump_down":
				$PlayerSounds/JumpDown.play()
			"alarm":
				playRandomSound($Guard/Alarm, guardAlarmSounds)			
			"jump_up":
				$PlayerSounds/JumpUp.play()
			"suspicious":
				playRandomSound($Guard/Suspicious ,guardSuspiciousSounds)
			"taser_hit":
				$PlayerSounds/TaserHit.play()
			"taser_deploy":
				$PlayerSounds/TaserDeploy.play()
			"minigame_fail":
				$MinigameSounds/MinigameFail.play()
			"camera_alarm":
				$CameraSounds/Alarm.play()
			"camera_beep":
				$CameraSounds/Beep.play()
			"wirecut":
				$MinigameSounds/WireCut.play()
			"keypad_clear":
				$MinigameSounds/Keypad/KeypadClear.play()
			"keypad_input":
				$MinigameSounds/Keypad/KeypadInput.play()
			"keypad_input_correct":
				$MinigameSounds/Keypad/KeypadInputCorrect.play()
			"keypad_input_wrong":
				$MinigameSounds/Keypad/KeypadInputWrong.play()
			"door_wooden_open":
				$DoorSounds/WoodenOpen.play()
			"door_wooden_close":
				$DoorSounds/WoodenClose.play()
			"door_metal_open":
				$DoorSounds/MetalOpen.play()
			"door_metal_close":
				$DoorSounds/MetalClose.play()
			"lockpick_hit":
				$MinigameSounds/Lockpick/Hit.play()
			"lockpick_miss":
				$MinigameSounds/Lockpick/Miss.play()
			"car_open":
				$ObjectSounds/CarOpen.play()
			"car_close":
				$ObjectSounds/CarClose.play()
			"minigame_success":
				$MinigameSounds/MinigameSuccess.play()
			"note_open":
				$ObjectSounds/NoteOpen.play()
			"player_footstep":
				playRandomSound($PlayerSounds/Footstep, playerFootstepSounds)
			"player_crouch_footstep":
				playRandomSound($PlayerSounds/CrouchWalk, playerCrouchWalkSounds)
			"type":
				$Type.play()
			"laser_detect":
				$ObjectSounds/LaserDetect.play()
			"chest_bounty":
				$ChestSounds/HasBounty.play()
			"chest_locked":
				$ChestSounds/Locked.play()
			"deskguard_detect":
				$Guard/DeskGuardDetect.play()
			"closet_open":
				$Closet/Open.play()
			"closet_close":
				$Closet/Close.play()
			"body_pickup":
				$StunnedBody/BodyPickup.play()
			"body_fall":
				$StunnedBody/BodyFall.play()
			"button":
				$Button.play()
			"game_hint":
				$GameHint.play()
			"dog_growl":
				$Dog/Growl.play()
			"dog_bark":
				playRandomSound($Dog/Bark, dogBarkSounds)
			"key_pickup":
				$KeyPickup.play()
			_: 
				print("error: sound not found - name: " + str(sound))


# Music Loop?
func _on_Music_finished():
	if musicPlayer.stream == hqIntro:
		musicPlayer.stream = hqMusic
	elif musicPlayer.stream == menuIntro:
		musicPlayer.stream = menuMusic
	musicPlayer.play()
	


func playRandomSound(audioPlayer, array: Array) -> void:
	randomize()
	audioPlayer.stream = array[randi() % array.size()]
	audioPlayer.play()


func onPlayMusic(level_type) -> void:
	match level_type:
		Types.LevelTypes.USA:
			musicPlayer.stream = westernMusic
			musicPlayer.play()
		Types.LevelTypes.USSR:
			musicPlayer.stream = easternMusic
			musicPlayer.play()
		"HQ":
			musicPlayer.stream = hqIntro
			musicPlayer.play()
		"Menu":
			musicPlayer.stream = menuIntro
			musicPlayer.play()
		_:
			print("error - music not found")


func onGameOver() -> void:
	$General/GameOver.play()

