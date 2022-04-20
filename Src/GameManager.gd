extends CanvasLayer

#warning-ignore:unused_class_variable

var state = Types.GameStates.Menu
var levelNode = null
var sure_detection_num: int = 0
var detected_value: int = 0
var current_level: int
var quest_index: int = 0


func _ready():
	# I know you guys like changing pause mode so I hardcoded it..
	self.pause_mode = Node.PAUSE_MODE_PROCESS
	$gameViewport/Viewport/LevelHolder.pause_mode = Node.PAUSE_MODE_STOP


	# Set Viewport Sizes to Project Settings
	$gameViewport/Viewport.size = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))
	$menuViewport/Viewport.size = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))

	Global.debugLabel = $Debug

	# Event Hooks
	Events.connect("cfg_music_set_volume", self, "setMusicVolume")
	Events.connect("cfg_sound_set_volume", self, "setSoundVolume")
	Events.connect("cfg_change_brightness", self, "setBrightness")
	Events.connect("cfg_change_contrast", self, "setContrast")

	Events.connect("cfg_switch_shader", self, "switchShader")
	Events.connect_signal("cfg_switch_fullscreen", self, "_switchFullscreen")
	Events.connect_signal("new_game", self, "_newGame")
	Events.connect_signal("menu_back", self, "_backToMenu")
	Events.connect("allowed_detections_updated", self, "onAllowedDetectionsUpdated")
	Events.connect("player_detected", self, "onPlayerDetected")


	switchTo(Types.GameStates.Menu)

	debugCheatMode()
	debugPlayerSkills()
	debugMoney()

	# Set (shared) world brightness
	$gameViewport/Viewport/WorldEnvironment.environment.adjustment_brightness = Global.userConfig.brightness
	$gameViewport/Viewport/WorldEnvironment.environment.adjustment_contrast = Global.userConfig.contrast


func debugCheatMode():
	Console.add_command("iamacheater", self, "debugActivateCheats")\
		.set_description("Activates cheats. Notice: You wont receive any achievements.")\
		.register()


func debugMoney():
#	var cat = Debug.addCategory("Money")
#	Debug.addOption(cat, "Add 1000", funcref(Global, "addMoney"), 1000)
#	Debug.addOption(cat, "Remove 200", funcref(Global, "addMoney"), -200)
	Console.add_command("money_add", Global, "addMoney")\
		.set_description("(CHEAT) Adds or substracts money.")\
		.add_argument('amount', TYPE_INT)\
		.add_restriction_condition(funcref(Global, "getCheatState"))\
		.register()


func debugPlayerSkills():
#	var cat = Debug.addCategory("PlayerSkills")
#	Debug.addOption(cat, "List", funcref(self, "debugListSkills"), null)
#	for skill in Global.upgrades:
#		Debug.addOption(cat, "add: " + skill.name, funcref(self, "debugAddSkill"), skill.id)
	Console.add_command("skill_list", self, "debugListSkills")\
		.set_description("List active skills.")\
		.register()

	Console.remove_command("skill_add")
	Console.add_command("skill_add", self, "debugAddSkill")\
		.set_description("(CHEAT) Adds a skill.")\
		.add_argument('id', TYPE_INT)\
		.add_restriction_condition(funcref(Global, "getCheatState"))\
		.register()

func debugActivateCheats():
	Global.gameState.cheats = true
	Console.write_line("Cheats have been activated.")

func debugAddSkill(id):
	Global.gameState.playerUpgrades.append(id)
	debugListSkills()

func debugListSkills():
	Console.write_line("Player skills:")
	Console.write_line(str(Global.gameState.playerUpgrades))

# State Transition Function
func switchTo(to):
	if to == Types.GameStates.Menu:
		$gameViewport.hide()
		$menuViewport.show()
		$menuViewport/Viewport/Menu.show()
		Events.emit_signal("play_music", Types.MusicType.title)
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
	if levelNode:
		levelNode.queue_free()
	levelNode = null


func reloadLevel():
	unloadLevel()
	loadLevel(current_level)
	sure_detection_num = 0
	get_tree().paused = false


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
func setSoundVolume(value):
	Global.userConfig.soundVolume = value
	Global.saveConfig()

# Event Hook: Update user config for music
func setMusicVolume(value):
	Global.userConfig.musicVolume = value
	Global.saveConfig()

func setBrightness(value):
	$gameViewport/Viewport/WorldEnvironment.environment.adjustment_brightness = value
	Global.userConfig.brightness = value
	Global.saveConfig()

func setContrast(value):
	$gameViewport/Viewport/WorldEnvironment.environment.adjustment_contrast = value
	Global.userConfig.contrast = value
	Global.saveConfig()

func switchShader(value):
	Global.userConfig.shader = value
	Global.saveConfig()

# Event Hook: Switch to fullscreen mode and update user config
func _switchFullscreen(value):
	Global.setFullscreen(value)



func onAllowedDetectionsUpdated(value: int) -> void:
	setDetectedValue(value)


func setDetectedValue(value: int) -> void:
	detected_value = value
	if detected_value == 0:
		Events.emit_signal("game_over")
		Events.emit_signal("minigame_forcefully_close")


func onPlayerDetected(detectionLevel) -> void:
	if detectionLevel == Types.DetectionLevels.Sure:
		setDetectedValue(detected_value - 1)
