extends Node2D


var music = [
	load("res://Assets/Music/western_world.ogg"), #	westernMusic = 0,
	load("res://Assets/Music/eastern_bloc.ogg"), #	easternMusic = 1,
	load("res://Assets/Music/hq_intro.ogg"), #	hqIntro,
	load("res://Assets/Music/hq_main.ogg"), #	hqMusic,
	load("res://Assets/Music/title_intro.ogg"), #	menuIntro,
	load("res://Assets/Music/title_main.ogg"), #	menuMusic,
	load("res://Assets/Music/hq_full.ogg"), #	hq_full,
	load("res://Assets/Music/surfin_ussr_full.ogg"), #	surfin_ussr,
	load("res://Assets/Music/rocket_full_.ogg"), #	rocket,
	load("res://Assets/Music/russia_win_full.ogg"), #	russia_win
	load("res://Assets/Music/title_full_.ogg"), # titleFull
	load("res://Assets/Music/bank_full_.ogg"), #bank
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


# Music Loop?
func _on_Music_finished():
	if musicPlayer.stream == music[Types.MusicType.hqIntro]:
		musicPlayer.stream = music[Types.MusicType.hqMusic]
	elif musicPlayer.stream == music[Types.MusicType.menuIntro]:
		musicPlayer.stream = music[Types.MusicType.menuMusic]
	musicPlayer.play()
	


func playRandomSound(audioPlayer, array: Array) -> void:
	randomize()
	audioPlayer.stream = array[randi() % array.size()]
	audioPlayer.play()


func onPlayMusic(music_id) -> void:
	musicPlayer.stream = music[music_id]
	musicPlayer.play()



func onGameOver() -> void:
	$General/GameOver.play()

