extends Node

# Steam Works Dummy


enum Steam_Status {STEAM_INIT_FAILED = 0, STEAM_NOT_RESPONDING, STEAM_CONNECTED}

var achievments = []

var online = false

var user = {
	owns = false,
	steamId = -1
}

func _ready():
	set_pause_mode(Node.PAUSE_MODE_PROCESS)
	set_process(false) # Processing is enabled after init()

	init()



func _overlay_toggled(toggle):
	get_tree().paused = toggle

func _user_stats_stored(gameID: int, result: int):
	if Global.NB_PLUGIN_CONFIG.gameId == gameID: # Check if its our game
		#print("Callback: _user_stats_stored")
		pass


func _user_achievement_stored(gameID: int, groupAchieve: bool, achName: String, currentProgress: int, maxProgress: int):
	if Global.NB_PLUGIN_CONFIG.gameId == gameID: # Check if its our game
		pass
#		print(groupAchieve)
#		print(achName)
#		print(currentProgress)
#		print(maxProgress)
#		print("Callback: _user_achievement_stored")


func _current_stats_received(gameID: int, result: int, userID: int):
	if Global.NB_PLUGIN_CONFIG.gameId == gameID: # Check if its our game
		achievments = []


func init():
	pass

func setAchievement(achievementName):
	pass


