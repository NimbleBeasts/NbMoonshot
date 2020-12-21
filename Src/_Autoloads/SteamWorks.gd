extends Node

enum Steam_Status {STEAM_INIT_FAILED = 0, STEAM_NOT_RESPONDING, STEAM_CONNECTED}

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


func _current_stats_received(gameID: int, result: int, userID: int):
	print("_current_stats_received")
	if Global.NB_PLUGIN_CONFIG.gameId == gameID:
		print("Call result: "+str(result))




func init():
	var init = Steam.steamInit()
	
	print("Steam: "+str(init))
	
	# General failure
	if init['status'] != 1:
		print("Failed to initialize Steam. "+str(init['verbal'])+" Shutting down...")
		# get_tree().quit()
	
	# Get Steam Information
	online = Steam.loggedOn()
	user.owns = Steam.isSubscribed()
	user.steamId = Steam.getSteamID()
	
	# Run Steam Callbacks
	set_process(true)
	
	if Global.DEBUG:
		print("Steam: Online: " + str(online) + " User: " + str(user))

func _process(delta):
	Steam.run_callbacks()
