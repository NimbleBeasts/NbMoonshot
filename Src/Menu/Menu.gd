extends Control

enum MenuState {Main, Settings, LoadGame}

func _ready():
	# Event Hooks
	Events.connect_signal("menu_back", self, "_back")
	Events.connect_signal("switch_sound", self, "_switchSound")
	Events.connect_signal("switch_music", self, "_switchMusic")
	Events.connect_signal("switch_fullscreen", self, "_switchFullscreen")

	$Version.bbcode_text = "[right]"+ Global.getVersionString() + "[/right]"

	switchTo(MenuState.Main)

	#TODO: remove code
	$Main/LevelSelect.clear()
	var counter = 0
	for level in Global.levels:
		$Main/LevelSelect.add_item(level, 0)
		counter += 1
	#$Main/LevelSelect.select(counter - 1)



# Play menu button sound
func playClick():
	Events.emit_signal("play_sound", "menu_click")

# Menu State Transition
func switchTo(to):
	hideAllMenuScenes()

	match to:
		MenuState.Main:
			$Main/ButtonPlay.grab_focus()
			$Main.show()
		MenuState.Settings:
			$Settings/ButtonSound.grab_focus()
			updateSettings()
			$Settings.show()
		MenuState.LoadGame:
			$LoadGame/ButtonLoad1.grab_focus()
			updateLoadGame()
			$LoadGame.show()
		_:
			print("Invalid menu state")

# Helper function for State Transition
func hideAllMenuScenes():
	# Add menu scenes here
	$Main.hide()
	$Settings.hide()
	$LoadGame.hide()


func loadGame(slot):
	Global.loadSave(slot)
	get_tree().paused = false
	playClick()
	Events.emit_signal("new_game", 0)

func updateLoadGame():
	var saves = Global.getSaveGameState()
	
	var i = 1
	for element in saves:
		var button = get_node("LoadGame/ButtonLoad" + str(i))
		if element == true: # File Exists
			button.updateLabel("Slot " + str(i))
			button.disabled = false
		else:
			button.updateLabel("Slot " + str(i))
			button.disabled = true
		i += 1


# Helper function to update the config labels
func updateSettings():
	if Global.userConfig.sound:
		$Settings/ButtonSound.updateLabel("Sound: On")
	else:
		$Settings/ButtonSound.updateLabel("Sound: Off")
	
	if Global.userConfig.music:
		$Settings/ButtonMusic.updateLabel("Music: On")
	else:
		$Settings/ButtonMusic.updateLabel("Music: Off")

	if Global.userConfig.fullscreen:
		$Settings/ButtonFullscreen.updateLabel("Fullscreen: On")
	else:
		$Settings/ButtonFullscreen.updateLabel("Fullscreen: Off")

###############################################################################
# Callbacks
###############################################################################

# Event Hook
func _switchSound(_val):
	updateSettings()

# Event Hook
func _switchMusic(_val):
	updateSettings()

# Event Hook
func _switchFullscreen(_val):
	updateSettings()

# Event Hook
func _back():
	switchTo(MenuState.Main)


func _on_ButtonPlay_button_up():
	get_tree().paused = false
	playClick()
	Events.emit_signal("new_game", $Main/LevelSelect.selected)


func _on_ButtonSettings_button_up():
	playClick()
	switchTo(MenuState.Settings)


func _on_ButtonExit_button_up():
	print("Ok, Bye! Thanks for playing.")
	get_tree().quit()


func _on_ButtonBack_button_up():
	playClick()
	switchTo(MenuState.Main)


func _on_ButtonSound_button_up():
	playClick()
	Events.emit_signal("switch_sound", !Global.userConfig.sound)


func _on_ButtonMusic_button_up():
	playClick()
	Events.emit_signal("switch_music", !Global.userConfig.music)


func _on_ButtonFullscreen_button_up():
	playClick()
	Events.emit_signal("switch_fullscreen", !Global.userConfig.fullscreen)
	updateSettings()



func _on_ButtonLoad_button_up():
	playClick()
	switchTo(MenuState.LoadGame)


func _on_ButtonCredits_button_up():
	pass # Replace with function body.


func _on_ButtonLoad1_button_up():
	loadGame(0)


func _on_ButtonLoad2_button_up():
	loadGame(1)


func _on_ButtonLoad3_button_up():
	loadGame(2)
