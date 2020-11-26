extends Control

var state = Types.GameStates.Menu
var levelNode = null
var possible_detection_num: int = 0
var sure_detection_num: int = 0
var detected_value: int = 0
var current_level: int
var quest_index: int = 0 

var debugWebMoney = false

func _ready():
	# I know you guys like changing pause mode so I hardcoded it..
	self.pause_mode = Node.PAUSE_MODE_PROCESS
	$gameViewport/Viewport/LevelHolder.pause_mode = Node.PAUSE_MODE_STOP
	
	
	# Set Viewport Sizes to Project Settings
	$gameViewport/Viewport.size = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))
	$menuViewport/Viewport.size = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))
	
	Global.debugLabel = $Debug

	# Event Hooks
	Events.connect_signal("switch_sound", self, "_switchSound")
	Events.connect_signal("switch_music", self, "_switchMusic")
	Events.connect_signal("switch_fullscreen", self, "_switchFullscreen")
	Events.connect_signal("new_game", self, "_newGame")
	Events.connect_signal("menu_back", self, "_backToMenu")
	Events.connect("player_detected", self, "_on_player_detected")
	Events.connect("allowed_detections_updated", self, "onAllowedDetectionsUpdated")
	
	Events.connect("web_monetization_pulse", self, "webMoneyPulse")
	
	switchTo(Types.GameStates.Menu)
	
	debugPlayerSkills()
	debugMoney()
	
func webMoneyPulse(paying):
	if paying or debugWebMoney:
		Global.addMoney(Global.gameConstant.webMoneyPerTick)
	else:
		print("WebMonetiazionPlugin not active or not paying. Use console to cheat. Missed: $" + str(Global.gameConstant.webMoneyPerTick))

func debugMoney():
	var cat = Debug.addCategory("Money")
	Debug.addOption(cat, "Add 1000", funcref(Global, "addMoney"), 1000)
	Debug.addOption(cat, "Remove 200", funcref(Global, "addMoney"), -200)
	Debug.addOption(cat, "WebMoneyEmulation Toggle", funcref(self, "debugWebMoneyEmulation"), null)

func debugWebMoneyEmulation(_d):
	debugWebMoney = !debugWebMoney
	print("DebugWebMoney:" + str(debugWebMoney))

func debugPlayerSkills():
	var cat = Debug.addCategory("PlayerSkills")
	Debug.addOption(cat, "List", funcref(self, "debugListSkills"), null)
	for skill in Global.upgrades:
		Debug.addOption(cat, "add: " + skill.name, funcref(self, "debugAddSkill"), skill.id)

func debugAddSkill(id):
	Global.gameState.playerUpgrades.append(id)
	
func debugListSkills(_d):
	print("PlayerSkills:")
	print(str(Global.gameState.playerUpgrades))

# State Transition Function
func switchTo(to):
	if to == Types.GameStates.Menu:
		$gameViewport.hide()
		$menuViewport.show()
		$menuViewport/Viewport/Menu.show()
	elif to == Types.GameStates.Game:
		$gameViewport.show()
		$menuViewport.hide()
		$menuViewport/Viewport/Menu.hide()
	state = to

# Load a level to the LevelHolder node
func loadLevel(number = 0):
	levelNode = load(Global.levels[number]).instance()
	current_level = number
	$gameViewport.get_node("Viewport/LevelHolder").add_child(levelNode)

# Unloads a loaded level
func unloadLevel():
	$gameViewport.get_node("Viewport/LevelHolder").remove_child(levelNode)
	levelNode.queue_free()
	levelNode = null


func reloadLevel():
	unloadLevel()
	loadLevel(current_level)
	possible_detection_num = 0
	sure_detection_num = 0
	print("reloaded level")


func getCurrentLevel():
	return levelNode

func getCurrentLevelIndex() -> int:
	return Global.levels.find(levelNode.filename)


func loadNextQuest() -> void:
	if Global.gameState["level"]["hasActiveMission"] and not Global.gameState["level"]["missionIsTutorial"]:
		unloadLevel()
		loadLevel(Global.gameState["level"]["lastActiveMission"])


###############################################################################
# Callbacks
###############################################################################

# Event Hook: Back from Game to Menu
func _backToMenu():
	unloadLevel()
	switchTo(Types.GameStates.Menu)

# Event Hook: New Game
func _newGame(startLevel = 0):
	if levelNode:
		unloadLevel()

	if startLevel == -1:
		startLevel = 0
	loadLevel(startLevel)
	switchTo(Types.GameStates.Game)


# Event Hook: Update user config for sound
func _switchSound(value):
	Global.userConfig.sound = value
	Global.saveConfig()

# Event Hook: Update user config for music
func _switchMusic(value):
	Global.userConfig.music = value
	Global.saveConfig()

# Event Hook: Switch to fullscreen mode and update user config
func _switchFullscreen(value):
	Global.setFullscreen(value)

# Event Hook: Player detection
func _on_player_detected(detection_level: int) -> void:
	match detection_level:
		Types.DetectionLevels.Possible:
			possible_detection_num += 1
			print("possible detection %s" % possible_detection_num)
			Events.emit_signal("possible_detection_num_changed", possible_detection_num)
		Types.DetectionLevels.Sure:
			sure_detection_num += 1
			print("sure detection %s" % sure_detection_num)
			setDetectedValue(detected_value - 1)
			print(detected_value)
			Events.emit_signal("sure_detection_num_changed", sure_detection_num)


func onAllowedDetectionsUpdated(value: int) -> void:
	setDetectedValue(value)


func setDetectedValue(value: int) -> void:
	detected_value = value
	if detected_value == 0:
		Events.emit_signal("game_over")
		Events.emit_signal("forcefully_close_minigame")
