extends Node2D


var music = [
	#affaire, affaire2, apollo, apollo11, atlas9, bank, chimpanzee, hq, listening, luna, rocket, rocket2, soyuz, title, ustriaescape, winlevel
	load("res://Assets/Music/-_Mx_affaire_BPM137_T4-4_Length77M_Intro3M.ogg"),
	load("res://Assets/Music/-_Mx_affaire2_BPM70_T4-4_Length64M_Intro8M.ogg"),
	load("res://Assets/Music/-_Mx_apollo_BPM72_T4-4_Length52M.ogg"),
	load("res://Assets/Music/-_Mx_apollo11_BPM107_T4-4_Length72M.ogg"),
	load("res://Assets/Music/-_Mx_atlas9_BPM80_T4-4_Length26M.ogg"),
	load("res://Assets/Music/-_Mx_bank_BPM114_T4-4_Length78M_Intro2M.ogg"),
	load("res://Assets/Music/-_Mx_chimpanzee_BPM174_T4-4_Length76M.ogg"),
	load("res://Assets/Music/-_Mx_hq_BPM130_T4-4_Length41M.ogg"),
	load("res://Assets/Music/-_Mx_ListeningDevice_BPM_94_T4-4_Length36M_Intro8M.ogg"),
	load("res://Assets/Music/-_Mx_luna_BPM100_T4-4_Length78M_Intro7M.ogg"),
	load("res://Assets/Music/-_Mx_rocket_BPM145_T4-4Length58M.ogg"),
	load("res://Assets/Music/-_Mx_rocket2_BPM92_T4-4_Length50M.ogg"),
	load("res://Assets/Music/-_Mx_soyuz_BPM64_T4-4_Length36M.ogg"),
	load("res://Assets/Music/-_Mx_title_BPM100_T4-4_Length32.2M_Intro5.2M.ogg"),
	load("res://Assets/Music/-_Mx_UstriaWinEscape_BPM122_T4-4_Length41M_Intro3.2M.ogg"),
	load("res://Assets/Music/-_Mx_UstriaWinLevel_T4-4_BPM130_Length24M.ogg"),

]

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
func _playSound(sound: String,_volume : float = 1.0, _pos : Vector2 = Vector2(0, 0)):
	if Global.userConfig.soundVolume > 0:
		match sound:				# should have made these enums instead, huh
			"test":
				$Test.position = _pos
				$Test.play()
			"door_wooden_open":
				$DoorSounds/WoodenOpen.position = _pos
				$DoorSounds/WoodenOpen.play()
			"door_wooden_close":
				$DoorSounds/WoodenClose.position = _pos
				$DoorSounds/WoodenClose.play()
			"door_metal_open":
				$DoorSounds/MetalOpen.position = _pos
				$DoorSounds/MetalOpen.play()
			"door_metal_close":
				$DoorSounds/MetalClose.position = _pos
				$DoorSounds/MetalClose.play()
			"car_open":
				$ObjectSounds/CarOpen.play()
			"car_close":
				$ObjectSounds/CarClose.play()
			"minigame_success":
				$MinigameSounds/MinigameSuccess.play()
			"minigame_fail":
				$MinigameSounds/MinigameFail.play()
			"key_pickup":
				$Key/KeyPickup.play()
			"key_use":
				$Key/KeyUse.play()
			"chest_bounty":
				$Chest_Bounty.play()
			_: 
				print("error: sound not found - name: " + str(sound))





func playRandomSound(audioPlayer, array: Array) -> void:
	randomize()
	audioPlayer.stream = array[randi() % array.size()]
	audioPlayer.play()


func onPlayMusic(music_id) -> void:
	musicPlayer.stream = music[music_id]
	musicPlayer.play()



func onGameOver() -> void:
	$General/GameOver.play()

