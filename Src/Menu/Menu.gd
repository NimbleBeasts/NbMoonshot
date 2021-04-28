extends Control

enum MenuState {Main, Settings, LoadGame, Credits}

var loadSlot = -1
var saveFiles

func _ready():
	# Event Hooks
	Events.connect_signal("menu_back", self, "_back")
	Events.connect_signal("cfg_switch_fullscreen", self, "_switchFullscreen")

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
			if $Main/LevelSelect.visible:
				$Main/LevelSelect/DebugButton.grab_focus()
			else:
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
	saveFiles = Global.getSaveGameState()
	
	var i = 1
	for element in saveFiles:
		var button = get_node("LoadGame/ButtonLoad" + str(i))
		if element.state == true: # File Exists
			button.updateLabel("Slot " + str(i))
			button.disabled = false
		else:
			button.updateLabel("Slot " + str(i))
			button.disabled = true
		i += 1

func updateSlotInfo(id):
	loadSlot = id

	var text = "Slot: " + str(id + 1)  + \
		"\n\n" + \
		"Date:" + str(saveFiles[id].date) + "\n" +\
		"Level:" + str(saveFiles[id].level)
	
	$LoadGame/LoadData.text = text


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
	updateSlotInfo(0)


func _on_ButtonLoad2_button_up():
	updateSlotInfo(1)


func _on_ButtonLoad3_button_up():
	updateSlotInfo(2)

func _on_ButtonLoadGame_button_up():
	if loadSlot >= 0:
		loadGame(loadSlot)



func _on_Copyright_meta_clicked(meta):
	#warning-ignore:return_value_discarded
	OS.shell_open(meta)


func _on_SoundSlider_value_changed(value):
	$Settings/SoundSlider/Percentage.set_text(str(value*10) + "%")
	Events.emit_signal("cfg_sound_set_volume", value)


func _on_MusicSlider_value_changed(value):
	$Settings/MusicSlider/Percentage.set_text(str(value*10) + "%")
	Events.emit_signal("cfg_music_set_volume", value)


func _on_ButtonFullscreen_button_up():
	playClick()
	Events.emit_signal("cfg_switch_fullscreen", !Global.userConfig.fullscreen)
	updateSettings()


func _on_ButtonShader_button_up():
	playClick()
	Events.emit_signal("cfg_switch_shader", !Global.userConfig.shader)
	updateSettings()


func _on_SteamTest_button_up():
	SteamWorks.setAchievement(Types.Achievement.Test)

