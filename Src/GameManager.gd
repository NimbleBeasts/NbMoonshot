extends Control

var state = Types.GameStates.Menu
var levelNode = null
var possible_detection_num: int = 0
var sure_detection_num: int = 0
var current_level: int
var boss_interaction_counter: int = 0
var secretary_interaction_counter: int = 0
var quest_index: int = 0 

func _ready():
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
	Events.connect("possible_detection_num_changed", self, "_on_possible_detection_num_changed")
	
	switchTo(Types.GameStates.Menu)
	
	debugPlayerSkills()
	
func debugPlayerSkills():
	var cat = Debug.addCategory("PlayerSkills")
	Debug.addOption(cat, "List", funcref(self, "debugListSkills"), null)
	for skill in Global.upgrades:
		Debug.addOption(cat, "add: " + skill.name, funcref(self, "debugAddSkill"), skill.id)

func debugAddSkill(id):
	Global.playerUpgrades.append(id)
	
func debugListSkills(_d):
	print("PlayerSkills:")
	print(str(Global.playerUpgrades))

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


func loadNextQuest() -> void:
	unloadLevel()
	loadLevel(quest_index)
	print(quest_index)


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
			print("possible detection")
			Events.emit_signal("possible_detection_num_changed", possible_detection_num)
		Types.DetectionLevels.Sure:
			sure_detection_num += 1
			print("sure detection")
			Events.emit_signal("sure_detection_num_changed", sure_detection_num)


func _on_possible_detection_num_changed(num: int) -> void:
	if num >= getCurrentLevel().allowed_detections:
		reloadLevel()
			
