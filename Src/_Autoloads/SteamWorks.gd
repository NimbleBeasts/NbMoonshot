extends Node

# Test Achievments:
# Enable console: steam://open/console
# achievement_clear 1492610 <achievement name>
# reset_all_stats 1492610


enum Steam_Status {STEAM_INIT_FAILED = 0, STEAM_NOT_RESPONDING, STEAM_CONNECTED}

var achievments = []

var online = false

var user = {
	owns = false,
	steamId = -1
}

func _ready():
	set_process(false) # Processing is enabled after init()
	
	init()
	
	if Steam.isSteamRunning():
		Steam.connect("current_stats_received", self, "_current_stats_received")
		Steam.connect("user_stats_stored", self, "_user_stats_stored")
		Steam.connect("user_achievement_stored", self, "_user_achievement_stored")


func _user_stats_stored(gameID: int, result: int):
	if Global.NB_PLUGIN_CONFIG.gameId == gameID: # Check if its our game
		print("Callback: _user_stats_stored")


func _user_achievement_stored(gameID: int, groupAchieve: bool, achName: String, currentProgress: int, maxProgress: int):
	if Global.NB_PLUGIN_CONFIG.gameId == gameID: # Check if its our game
#		print(groupAchieve)
#		print(achName)
#		print(currentProgress)
#		print(maxProgress)
		print("Callback: _user_achievement_stored")


func _current_stats_received(gameID: int, result: int, userID: int):
	if Global.NB_PLUGIN_CONFIG.gameId == gameID: # Check if its our game
		
		achievments = []
		
		if result == Steam.RESULT_OK:
			print("Achievments received:")
			for ach in Types.AchievementStrings:
				print(Steam.getAchievement(ach))
				if Steam.getAchievement(ach).achieved:
					achievments.append(ach)
		else:
			print("Steam Error: Cant retrieve stats")


func init():
	var init = Steam.steamInit()
	
	print("Steam: "+str(init))
	
	# General failure
	if init['status'] != 1:
		print("Failed to initialize Steam. "+str(init['verbal'])+" Shutting down...")
		return
	
	# Get Steam Information
	online = Steam.loggedOn()
	user.owns = Steam.isSubscribed()
	user.steamId = Steam.getSteamID()

	# Stats are already requested within another request. 
#	if not Steam.requestCurrentStats():
#		print("Steam Error: Getting current stats")
	
	# Run Steam Callbacks
	set_process(true)
	
	if Global.DEBUG:
		print("Steam: Online: " + str(online) + " User: " + str(user))

func setAchievement(achievementId):
	if online:
		if achievementId < Types.Achievement.size():
			Steam.setAchievement(Types.AchievementStrings[achievementId])
			Steam.storeStats()

	
func _process(delta):
	Steam.run_callbacks()
