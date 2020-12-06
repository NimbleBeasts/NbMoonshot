extends Control

enum MenuState {Main, Settings, LoadGame, Credits}

func _ready():
	# Event Hooks
	Events.connect_signal("menu_back", self, "_back")
	Events.connect_signal("switch_fullscreen", self, "_switchFullscreen")

	$Version.bbcode_text = "[right]"+ Global.getVersionString() + "[/right]"

	switchTo(MenuState.Main)

	if Global.DEBUG:
		$Main/LevelSelect.show()
		$Main/LevelSelect.clear()
		var counter = 0
		for level in Global.levels:
			$Main/LevelSelect.add_item(level, 0)
			counter += 1
		$Main/LevelSelect.select(counter - 1)
	else:
		$Main/LevelSelect.hide()



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
			$Settings/SoundSlider.grab_focus()
			updateSettings()
			$Settings.show()
		MenuState.LoadGame:
			$LoadGame/ButtonLoad1.grab_focus()
			updateLoadGame()
			$LoadGame.show()
		MenuState.Credits:
			$Credits/ButtonBack.grab_focus()
			$Credits.show()
		_:
			print("Invalid menu state")

# Helper function for State Transition
func hideAllMenuScenes():
	# Add menu scenes here
	$Main.hide()
	$Settings.hide()
	$LoadGame.hide()
	$Credits.hide()


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
	$Settings/SoundSlider.value = Global.userConfig.soundVolume
	$Settings/SoundSlider/Percentage.set_text(str(Global.userConfig.soundVolume*10) + "%")

	$Settings/MusicSlider.value = Global.userConfig.musicVolume
	$Settings/MusicSlider/Percentage.set_text(str(Global.userConfig.musicVolume*10) + "%")

	if Global.userConfig.fullscreen:
		$Settings/ButtonFullscreen.updateLabel("On")
	else:
		$Settings/ButtonFullscreen.updateLabel("Off")

###############################################################################
# Callbacks
###############################################################################


# Event Hook
func _switchFullscreen(_val):
	updateSettings()

# Event Hook
func _back():
	switchTo(MenuState.Main)



func _on_DebugButton_button_up():
	get_tree().paused = false
	playClick()
	Events.emit_signal("new_game", $Main/LevelSelect.selected)


func _on_ButtonPlay_button_up():
	get_tree().paused = false
	playClick()
	Events.emit_signal("new_game", 0)
	Global.newGameState()
	
func _on_ButtonSettings_button_up():
	playClick()
	switchTo(MenuState.Settings)


func _on_ButtonExit_button_up():
	print("Ok, Bye! Thanks for playing.")
	get_tree().quit()


func _on_ButtonBack_button_up():
	playClick()
	switchTo(MenuState.Main)


func _on_ButtonLoad_button_up():
	playClick()
	switchTo(MenuState.LoadGame)


func _on_ButtonCredits_button_up():
	playClick()
	switchTo(MenuState.Credits)


func _on_ButtonLoad1_button_up():
	loadGame(0)


func _on_ButtonLoad2_button_up():
	loadGame(1)


func _on_ButtonLoad3_button_up():
	loadGame(2)


func _on_Copyright_meta_clicked(meta):
	OS.shell_open(meta)



func _on_SoundSlider_value_changed(value):
	$Settings/SoundSlider/Percentage.set_text(str(value*10) + "%")
	Events.emit_signal("sound_set_volume", value)


func _on_MusicSlider_value_changed(value):
	$Settings/MusicSlider/Percentage.set_text(str(value*10) + "%")
	Events.emit_signal("music_set_volume", value)


func _on_ButtonFullscreen_button_up():
	playClick()
	Events.emit_signal("switch_fullscreen", !Global.userConfig.fullscreen)
	updateSettings()


func _on_ButtonShader_button_up():
	playClick()
	Events.emit_signal("switch_shader", !Global.userConfig.shader)
	updateSettings()
