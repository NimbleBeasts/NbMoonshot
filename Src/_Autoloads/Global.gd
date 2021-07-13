###############################################################################
# Copyright (c) 2020 NimbleBeasts
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
###############################################################################

extends Node

#warning-ignore-all:unused_class_variable

# Version
const GAME_VERSION = 0.5
const CONFIG_VERSION = 3 # Used for config migration

# Debug Options
const DEBUG = true


# Nb Plugin Config
const NB_PLUGIN_CONFIG = {
	"gameId": 1492610,
	"filePassword": "password",
	"magic": "magiccode",
	"devlogUrl": "https://raw.githubusercontent.com/NimbleBeasts/GameLogs/master/GameOff_"+ str(GAME_VERSION) +".txt"
}

const supportedResolutions = [
	Vector2(1280, 720), #our default
	Vector2(1366, 768), #7.47%
	Vector2(1920, 1080), #67.60%
	Vector2(2560, 1440), #8.23%
	Vector2(3840, 2160) #2.41%
	]

# Level Array
# mago: Renaming the missions, kept the order for now. Add your new level before testlevel.tscn
const levels = [
	"res://Src/Levels/HQ_Level.tscn",
	"res://Src/Levels/Level1.tscn",
	"res://Src/Levels/Level2.tscn",
	"res://Src/Levels/Level3.tscn",
	"res://Src/Levels/Level4.tscn",
	"res://Src/Levels/Level5.tscn",
	"res://Src/Levels/Level6.tscn",
	"res://Src/Levels/Level7.tscn", 
	"res://Src/Levels/Level8.tscn",
	"res://Src/Levels/Level9.tscn",
	"res://Src/Levels/Level10.tscn",
	"res://Src/Levels/Level11.tscn",
	"res://Src/Levels/Level12.tscn",
	"res://Src/Levels/Level13.tscn",
	"res://Src/Levels/Level14.tscn",
	"res://Src/Levels/Level15.tscn",
	"res://Src/Levels/Level16.tscn",
	"res://Src/Levels/Level17.tscn",
	"res://Src/Levels/Level18.tscn",
	"res://Src/Levels/Level19.tscn",
	"res://Src/Levels/TestLevel.tscn",
	"res://Src/Levels/Level20.tscn", 

]


# Upgrades
const upgrades = [
	{id = 0, name="UPGRADE_POWERBANK_TITLE", desc="UPGRADE_POWERBANK_DESC", cost=300},
	{id = 1, name="UPGRADE_DOG_TITLE",       desc="UPGRADE_DOG_DESC", cost=300},
	{id = 2, name="UPGRADE_ALARM_TITLE",     desc="UPGRADE_ALARM_DESC", cost=300},
	{id = 3, name="UPGRADE_SPRINT_TITLE",    desc="UPGRADE_SPRINT_DESC", cost=150},
	{id = 4, name="UPGRADE_SNEAK_TITLE",     desc="UPGRADE_SNEAK_DESC", cost=200},
	{id = 5, name="UPGRADE_DARKNET_TITLE",   desc="UPGRADE_DARKNET_DESC", cost=200},
	{id = 6, name="UPGRADE_LOCK_TITLE",      desc="UPGRADE_LOCK_DESC", cost=300},
	{id = 7, name="UPGRADE_DISTRACT_TITLE",  desc="UPGRADE_DISTRACT_DESC", cost=200}
]

const gameConstant = {
	basicLoot = 20,
	upgradeDarkNetModifier = 1.25,
	lightLevels = [Color("#b194a0"), Color("#787878"), Color("#c4cfd6")],
	progress = [ #Mission Progress
		[20, 22, 23, 26, 28, 30, 32, 34, 36, 38, 40, 46, 53, 60, 66, 73, 80, 86, 93, 100], #USA
		[30, 32, 36, 39, 42, 45, 48, 52, 55, 57, 61, 65, 67, 67, 74, 77, 80, 83, 86, 89], #USSR
		[ 0,  5, 10, 12, 15, 17, 25, 30, 35, 35, 40, 43, 47, 50, 54, 57, 60, 64, 67, 72], #USTRIA
	]
}


var gameState = {
	date = 0,
	cheats = false,
	playerUpgrades = [],
	money = 0,
	playerOfficeDoorIsOpen = false,
	level = {
		# Game will only be saveable during missions in the HQ. So it will be easier to track:
		hasActiveMission = false,
		lastActiveMission = -1,
		missionIsTutorial = false
	},

	interactionCounters = {
		boss = 0,
		secretary = 0
	},

	sabotageCounters = {
		usa = 0,
		ussr = 0
	}	

} setget setGameState

# Debug Settings
#warning-ignore:unused_class_variable
var debugLabel = null


# User Config - These are also the default values
var userConfig = {
	"configVersion": CONFIG_VERSION,
	"highscore": 0,
	"soundVolume": 8,
	"musicVolume": 8,
	"shader": true,
	"fullscreen": false,
	"brightness": 1.0,
	"contrast": 1.0,
	"resolution": {"w": 1280, "h": 720},
	"language": "en"
}

# For the achievement its easiest for now to double track these data:
var lives = 0
var allowed_detections = 0


# RNG base
var rng = RandomNumberGenerator.new()
var stateSeed = int(3458764513820540928)

# Node References
var player
onready var screen_center := get_viewport().get_visible_rect().size / 2
onready var screen_bottom_center = Vector2(get_viewport().get_visible_rect().size.x / 2, get_viewport().get_visible_rect().size.y + 500)
onready var game_manager := get_node("/root/GameManager")

var languageLocale: String = "en"
var returnedFromSabotageMission: bool = false


###############################################################################
# Functions
###############################################################################

func _ready():
	print("Starting: " + str(ProjectSettings.get_setting("application/config/name")) + " v" + getVersionString())
	print("Date: " + getDateTimeStringFromUnixTime(getLocalUnixTime()))
	print("Debug: " + str(OS.is_debug_build()))
	print("Soft-Debug: "+ str(DEBUG))
	rng.randomize()
	loadConfig()
	switchFullscreen()

func getCheatState():
	if gameState.has("cheats"):
		if gameState.get("cheats"):
			return true
	return false

func getDateTimeStringFromUnixTime(unixTime):
	var dict = OS.get_datetime_from_unix_time(unixTime)
	return "%0*d" % [2, dict.day] + "/"  + "%0*d" % [2, dict.month] + "/" + str(dict.year) + " - " + "%0*d" % [2, dict.hour] + ":" + "%0*d" % [2, dict.minute]

func getLocalUnixTime():
	#Unix Timestamp is GMT based, but we want local time instead
	var date = OS.get_datetime_from_unix_time(OS.get_unix_time())
	var time = OS.get_time()
	date.hour = time.hour
	date.minute = time.minute
	return OS.get_unix_time_from_datetime(date)

func getSaveGameState():
	var retVal = []
	for i in range(3):
		var saveFile = File.new()
		if saveFile.file_exists("user://save_"+ str(i) + ".cfg"):
			var date = -1
			var level = -1
			saveFile.open("user://save_"+ str(i) + ".cfg", File.READ)
			var data = parse_json(saveFile.get_line())
			if data.has("date") and data.has("interactionCounters"):
				date = data.date
				level = data.interactionCounters.boss
			retVal.append({"state": true, "date": date, "level": level})
		else:
			retVal.append({"state": false, "date": 0, "level": -1})
	return retVal

# Save Game
func saveGame(slotId):
	var saveFile = File.new()
	gameState.date = getLocalUnixTime()
	saveFile.open("user://save_"+ str(slotId) + ".cfg", File.WRITE)
	saveFile.store_line(to_json(gameState))
	saveFile.close()
	Events.emit_signal("hud_game_hint", tr("HUD_GAME_SAVED"))
	Events.emit_signal("hud_save_window_exited")

# Load Game
func loadSave(slotId):
	var saveFile = File.new()
	if not saveFile.file_exists("user://save_"+ str(slotId) + ".cfg"):
		print("Save Game Not Found")
	
	saveFile.open("user://save_"+ str(slotId) + ".cfg", File.READ)
	var data = parse_json(saveFile.get_line())
	gameState = data.duplicate()

# Config Save
func saveConfig():
	var cfgFile = File.new()
	cfgFile.open("user://config.cfg", File.WRITE)
	cfgFile.store_line(to_json(userConfig))
	cfgFile.close()

# Config Load
func loadConfig():
	var cfgFile = File.new()
	if not cfgFile.file_exists("user://config.cfg"):
		saveConfig()
		return
	
	cfgFile.open("user://config.cfg", File.READ)
	var data = parse_json(cfgFile.get_line())
	cfgFile.close()
	
	# Check if the user has an old config, so update it
	if data.configVersion < CONFIG_VERSION:
		userConfig = migrateConfig(data)
		saveConfig()

	# Copy over userConfig
	userConfig.highscore = data.highscore
	userConfig.fullscreen = data.fullscreen
	userConfig.musicVolume = data.musicVolume
	userConfig.soundVolume = data.soundVolume
	userConfig.shader = data.shader
	userConfig.resolution = data.resolution
	userConfig.brightness = data.brightness
	userConfig.contrast = data.contrast
	userConfig.language = data.language
	# When stuck here, the config attributes have been changed.
	# Delete the Config.cfg to solve this issue.
	# Project->Open Project Data Folder-> Config.cfg
	#
	# Do NOT optimize it:
	# Sure this can be just copied, but you may miss if some settings are not
	# saved correctly. Also for updates please consider the migration mechanism.

# Config Migration
func migrateConfig(data):
	for _i in range(data.configVersion, CONFIG_VERSION):
		match str(data.configVersion):
			"0":
				#update config here
				data.soundVolume = 8
				data.musicVolume = 8
				data.shader = true
				data.configVersion = 1
			"1":
				data.resolution = {"w": 1280, "h": 720}
				data.brightness = 1.0
				data.contrast = 1.0
				data.configVersion = 2
			"2":
				data.language = "en"
				data.configVersion = 3
			_:
				print("error: migration variant ("+ str(data.configVersion)+ ") not found")
	return data


# Set Fullscreen Mode
func setFullscreen(val: bool):
	userConfig.fullscreen = val
	saveConfig()
	
	switchFullscreen()

func setResolution(val: int):
	userConfig.resolution = {
		"w": supportedResolutions[val].x,
		"h": supportedResolutions[val].y
	}
	saveConfig()
	
	switchResolution()

func newGameState() -> void:
	Global.gameState = {
	playerUpgrades = [],
	money = 0,
	playerOfficeDoorIsOpen = false,
	level = {
		# Game will only be saveable during missions in the HQ. So it will be easier to track:
		hasActiveMission = false,
		lastActiveMission = -1,
		missionIsTutorial = false
	},

	interactionCounters = {
		boss = 0,
		secretary = 0
	}

}

func switchResolution():
	OS.set_window_size(Vector2(userConfig.resolution.w, userConfig.resolution.h))
	#Center the window
	OS.center_window()

# Perform Fullscreen Switch
func switchFullscreen():
	if not userConfig.fullscreen:
		OS.window_fullscreen = false
		switchResolution()
		
	else:
		OS.window_fullscreen = true

# PRNG
func prng():
	stateSeed = int((rng.randi() + 1) * stateSeed) + 1
	return abs(stateSeed)

# PRNG by Chance in Percentage
func prngByChance(chanceInPercent):
	var value = prng() % 100
	if value <= chanceInPercent:
		return true
	return false

# Get Version
func getVersion():
	return GAME_VERSION
	
# Get Version String
func getVersionString():
	var versionString = "%2.1f" % (GAME_VERSION) 
	
	if DEBUG:
		versionString += "-debug"

	return versionString

# Player Handling
func addMoney(amount):
	gameState.money += amount
	print("PlayerMoney: " + str(gameState.money))
	Events.emit_signal("hud_update_money", gameState.money, amount)
	
	#Achievement
	if gameState.money >= 1000:
		SteamWorks.setAchievement("STEAM_ACH_4") #Big Money


func playerHasUpgrade(type):
	if gameState.playerUpgrades.find(type) == -1:
		return false
	return true


# adds upgrade by Types.UpgradeTypes
func addUpgrade(new_upgrade: int) -> void:
	if not playerHasUpgrade(new_upgrade):
		gameState.playerUpgrades.append(new_upgrade)


func getUpgradeInfo(upgrade_type: int) -> Dictionary:
	for upgrade in upgrades:
		var upgrade_values: Array = upgrade.values()
		if upgrade_values[0] == upgrade_type:
			return upgrade
		
	return {}


func setGameState(value: Dictionary) -> void:
	gameState = value

func startTimerOnce(timer: Timer) -> void:
	if timer.is_stopped():
		timer.start(timer.wait_time)


func changeLanguageLocale(newLocale: String) -> void:
	languageLocale = newLocale
	get_tree().call_group("HasTranslationSupport", "loadTranslation")


func calcAudioPosition(globalPosition):
	assert(player)
	return globalPosition - player.global_position + Vector2(320, 180)
