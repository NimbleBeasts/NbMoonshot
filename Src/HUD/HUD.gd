
extends Control


var level_lightning_level = 0
var inMinigame: bool = false


var count = 0
var detected_value: int

var nextText: String
var nextName: String
var nextNameColor: String
var nextPotrait: int

var currentText: String
var hideWithE: bool = false
var currentSelectedUpgrade: int = 0
var dialogIsTyping: bool = false
var canSayNext: bool = false
var isGameOver: bool = false
var levelHint: String
var multipage: bool

var inMissionBriefing: bool

onready var dialogTypeTimer: Timer = $HUDLayer/Display/Dialog/DialogueTypeTimer

var emittingNode = null

var selectedSave = -1
var saveFiles

func _ready():
	#$AlarmIndicator/Label.set_text(str(detected_value)) TODO

	# Connect signals
	hookSetup()

	if Global.userConfig.shader:
		$HUDLayer/Shader.show()
	else:
		$HUDLayer/Shader.hide()

	if Global.DEBUG:
		$HUDLayer/Display/IngameMenu/DebugPromo.show()
#		var cat = Debug.addCategory("HUD")
#		Debug.addOption(cat, "ShaderToggle", funcref(self, "debugShaderToggle"), null)
#		Debug.addOption(cat, "HudToggle", funcref(self, "debugHudToggle"), null)
#		Debug.addOption(cat, "LightningToggle", funcref(self, "debugLightToggle"), null)
	else:
		if $IngameMenu/DebugPromo:
			$IngameMenu/DebugPromo.hide()

	Console.remove_command("shader_toggle")
	Console.add_command("shader_toggle", self, "debugShaderToggle")\
		.set_description("Toggle retro shader.")\
		.register()
	Console.remove_command("hud_toggle")
	Console.add_command("hud_toggle", self, "debugHudToggle")\
		.set_description("Toggle hud.")\
		.register()
	Console.remove_command("lightning_toggle")
	Console.add_command("lightning_toggle", self, "debugLightToggle")\
		.set_description("Toggle lightning.")\
		.register()

	$HUDLayer/Display/GUI.visible = true
	detected_value = Global.game_manager.getCurrentLevel().allowed_detections

	$HUDLayer/Display/Dialog.hide()

func _physics_process(_delta):
	# Hide Note
	if Input.is_action_just_pressed("close_menu"):
		if $HUDLayer/Display/Note.visible:
			$HUDLayer/Display/Note.hide()
			Events.emit_signal("hud_note_exited", emittingNode)
		elif $HUDLayer/Display/Dialog.visible:
			Events.emit_signal("hud_dialogue_hide")
		elif $HUDLayer/Display/Upgrades.visible:
			$HUDLayer/Display/Upgrades.hide()
			Events.emit_signal("player_unblock_movement")
		elif $HUDLayer/Display/SaveGame.visible:
			onHideSave()

	if Input.is_action_just_pressed("menu"):
		if $HUDLayer/Display/IngameMenu.visible:
			hideMenu()
		else:
			if not inMinigame:
				showMenu()
			else:
				Events.emit_signal("minigame_forcefully_close")
	
	setDialogIsTyping($HUDLayer/Display/Dialog/Text.visible_characters != $HUDLayer/Display/Dialog/Text.text.length() and $HUDLayer/Display/Dialog.visible)


	if levelHint != "":
		if not $HUDLayer/Display/Dialog.visible:
			Events.emit_signal("hud_game_hint", levelHint)
			levelHint = ""
		

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if $HUDLayer/Display/Note.visible:
			$HUDLayer/Display/Note.hide()
			get_tree().set_input_as_handled()
			Events.emit_signal("hud_note_exited", emittingNode)

func setLightLevel(level):
	level_lightning_level = level
	$LevelModulation.color = Global.gameConstant.lightLevels[level]


func photoFlash():
	$HUDLayer/PhotoFlash/AnimationPlayer.play("detection")

func showGameHintNotification(text):
	$HUDLayer/GameHintNotification.set_text(text)
	$HUDLayer/GameHintNotification.show()
	$HUDLayer/GameHintNotification/GameHintAnimationPlayer.play("pop")
	$GameHint.play()

func _on_GameHintAnimationPlayer_animation_finished(_anim_name):
	$HUDLayer/GameHintNotification.hide()


func showGameOverNotification():
	$HUDLayer/GameOverNotification.show()
	$HUDLayer/GameOverNotification/GameOverNotifcationAnimationPlayer.play("pop")

	
func _on_GameOverNotifcationAnimationPlayer_animation_finished(_anim_name):
	$HUDLayer/GameOverNotification.hide()
	Events.emit_signal("hud_game_over_exited")


func showMissionProgress():
	$HUDLayer/Display/MissionProgress.updateProgress()

func showMissionBriefing(level):
	
	$HUDLayer/LevelFade/AnimationPlayer.play_backwards("fade_out")
	
	$HUDLayer/Display/MissionBriefing/StartMissionButton.grab_focus()
	$HUDLayer/Display/MissionBriefing.setLevel(level)
	$HUDLayer/Display/MissionBriefing.show()
	inMissionBriefing = true


func debugLightToggle(_d = null):
	level_lightning_level += 1
	
	if level_lightning_level >= Types.LevelLightning.size():
		level_lightning_level = 0
	
	Events.emit_signal("hud_light_level", level_lightning_level)
	
	print("LightLevel: " + str(Types.LevelLightning.keys()[level_lightning_level]))


func debugShaderToggle(_d = null):
	if $HUDLayer/Shader.visible:
		$HUDLayer/Shader.hide()
	else:
		$HUDLayer/Shader.show()

func debugHudToggle(_d = null):
	if $HUDLayer/Display.visible:
		$HUDLayer/Display.hide()
	else:
		$HUDLayer/Display.show()

func showSave():
	#dont open if allready opend :)
	if $HUDLayer/Display/SaveGame.is_visible_in_tree():
		return

	Events.emit_signal("player_block_movement")
	saveFiles = Global.getSaveGameState()
	
	var i = 1
	for element in saveFiles:
		var button = get_node("HUDLayer/Display/SaveGame/Menu/ButtonSave" + str(i))
		if element.state == true: # File Exists
			button.updateLabel("Slot " + str(i) + " (Overwrite)")
		else:
			button.updateLabel("Slot " + str(i) + " (New)")
		i += 1
	$HUDLayer/Display/SaveGame.show()
	$HUDLayer/Display/SaveGame/Menu.grab_focus()


func save(slot):
	Global.saveGame(slot)


func moneyUpdate(total, change):
	if $HUDLayer/Display/Upgrades.visible:
		# Update button if money is enough
		upgradeSelect(currentSelectedUpgrade)

	$HUDLayer/Display/HudBar.updateMoney(total, change)

func taserUpdate(value):
	var clamped = clamp( value, 0, 3)
	#TODO
	#$ChargeIndicator.frame = 3 - clamped
	#$ChargeIndicator/Label.set_text(str(value))


func alarmIndication(type):
	if detected_value - 1 >= 0:
		detected_value -= 1
		$HUDLayer/DetectFlash/AnimationPlayer.play("detection")
		#$AlarmIndicator/AlarmAnimation.play("downgrade")
		#$AlarmIndicator/Label.set_text(str(detected_value))
		
		$HUDLayer/Display/HudBar.updateAlarm(detected_value)


func allowedDetectionsUpdate(value) -> void:
	detected_value = value 
	#$AlarmIndicator/Label.set_text(str(detected_value))
	$HUDLayer/Display/HudBar.updateAlarm(detected_value)

	
func showNote(node, type, text):
	if type == Types.NoteType.Local:
		$HUDLayer/Display/Note.texture = preload("res://Assets/HUD/NoteLocal.png")
	else:
		$HUDLayer/Display/Note.texture = preload("res://Assets/HUD/Note.png")

	emittingNode = node
	$HUDLayer/Display/Note/Text.bbcode_text = str(text)
	$NoteOpen.play()
	$HUDLayer/Display/Note.show()


func updateUpgrades():
	# Clear old results
	for node in $HUDLayer/Display/Upgrades/Grid.get_children():
		node.disabled = false
	for upgradeId in Global.gameState.playerUpgrades:
		get_node("HUDLayer/Display/Upgrades/Grid/UpgradeButton" + str(upgradeId)).disabled = true


func _on_UpgradeButton_button_up():
	var upgrade = Global.upgrades[currentSelectedUpgrade]
	if Global.gameState.money >= upgrade.cost:
		Global.addUpgrade(currentSelectedUpgrade)
		Global.addMoney(-upgrade.cost)
		upgradeSelect(currentSelectedUpgrade)
		Events.emit_signal("player_upgrades_do")
		updateUpgrades()
	

func upgradeSelect(id):
	currentSelectedUpgrade = id
	var upgrade = Global.upgrades[id]
	$HUDLayer/Display/Upgrades/InfoBox/Titel.set_text(upgrade.name + " $" + str(upgrade.cost))
	$HUDLayer/Display/Upgrades/InfoBox/Description.bbcode_text = upgrade.desc
	
	if -1 == Global.gameState.playerUpgrades.find(id):
		if Global.gameState.money >= upgrade.cost:
			$HUDLayer/Display/Upgrades/InfoBox/UpgradeButton.updateLabel("Buy Upgrade")
			$HUDLayer/Display/Upgrades/InfoBox/UpgradeButton.disabled = false
		else:
			$HUDLayer/Display/Upgrades/InfoBox/UpgradeButton.updateLabel("Not Enough Cash")
			$HUDLayer/Display/Upgrades/InfoBox/UpgradeButton.disabled = true
	else:
		$HUDLayer/Display/Upgrades/InfoBox/UpgradeButton.updateLabel("Already Owned")
		$HUDLayer/Display/Upgrades/InfoBox/UpgradeButton.disabled = true


func showUpgrade():
	if not $HUDLayer/Display/Upgrades.visible:
		# Set focus so we can use gamepad with ui
		$HUDLayer/Display/Upgrades/Grid/UpgradeButton0.grab_focus()
		upgradeSelect(0)

		updateUpgrades()
		$HUDLayer/Display/Upgrades.show()


func showDialog(pname: String, nameColor: String, text: String, isMultipage: bool, portrait: int) -> void:
	nextText = ""
	nextName = ""
	nextNameColor = ""
	nextPotrait = 0
	 # for multipage dialogue, checks if new line and stores the text after the new line in nextText and other info in variables
	if "\n" in text:
		nextText = text.substr(text.find("\n") + 1)
		text.erase(text.find("\n"), 300) # erases from original text so that it won't have the next page text
		nextName = pname
		nextNameColor = nameColor
		nextPotrait = portrait

	$HUDLayer/Display/Dialog/Text.bbcode_text = "[color="+nameColor+"]"+pname+"[/color]: " + text
	$HUDLayer/Display/Dialog/Text.visible_characters = pname.length()
	$HUDLayer/Display/Dialog.show()
	$HUDLayer/Display/Dialog/Sprite.frame = portrait
	
	currentText = text
	multipage = isMultipage
	typeDialog()


# call this function to hide dialogue instead of simply hiding it 
func hideDialog() -> void:
	$HUDLayer/Display/Dialog.hide()
	Events.emit_signal("hud_dialogue_exited")
	dialogTypeTimer.stop()
	$HUDLayer/Display/Dialog/Text.visible_characters = 0
	Events.emit_signal("player_unblock_movement")
	Events.emit_signal("player_state_set", Types.PlayerStates.Normal)


func showMenu():
	$HUDLayer/Display/IngameMenu.show()
	$HUDLayer/Display/IngameMenu/Menu/ButtonReturn.grab_focus()
	
	var value = Global.userConfig.musicVolume
	$HUDLayer/Display/IngameMenu/Menu/MusicSlider/Percentage.set_text(str(value*10)+"%")
	$HUDLayer/Display/IngameMenu/Menu/MusicSlider.value = value

	value = Global.userConfig.soundVolume
	$HUDLayer/Display/IngameMenu/Menu/SoundSlider/Percentage.set_text(str(value*10)+"%")
	$HUDLayer/Display/IngameMenu/Menu/SoundSlider.value = value
	
	get_tree().paused = true


func hideMenu():
	$HUDLayer/Display/IngameMenu.hide()
	if not inMissionBriefing:
		get_tree().paused = false
	else:
		$HUDLayer/Display/MissionBriefing/StartMissionButton.grab_focus()


func updateLightLevel(newLightLevel):
	match newLightLevel:
		Types.LightLevels.Dark:
			$LightIndicator.frame = 2
		Types.LightLevels.BarelyVisible:
			$LightIndicator.frame = 1
		Types.LightLevels.FullLight:
			$LightIndicator.frame = 0
		_:
			print("HUD: Illegal light level provided")
	

func updateAudioLevel(newAudioLevel, _audio_pos, _emitter): #TODO: audio_pos needed?
	if newAudioLevel >= 0 and newAudioLevel < Types.AudioLevels.size():
		$AudioIndicator.frame = newAudioLevel
	else:
		print("HUD: Illegal audio level provided")
	
	$AudioIndicator/GoBackToNormal.start()


func _on_GoBackToNormal_timeout() -> void:
	$AudioIndicator.frame = 2


func onHideSave() -> void:
	Events.emit_signal("player_unblock_movement")
	$HUDLayer/Display/SaveGame.hide()

	


func onDialogTypeTimerTimeout() -> void:
	if $HUDLayer/Display/Dialog/Text.text.length() != $HUDLayer/Display/Dialog/Text.visible_characters:
		$HUDLayer/Display/Dialog/Text.visible_characters += 1
		$Type.play()
	else:
		dialogTypeTimer.stop()


func typeDialog() -> void:
	dialogTypeTimer.start()
	

		
func setDialogIsTyping(value: bool) -> void:
	if dialogIsTyping != value:
		dialogIsTyping = value
		Events.emit_signal("dialog_typing_changed", dialogIsTyping)




func onLevelHint(hint: String) -> void:
	levelHint = hint

func onNoBranchOptionPressed() -> void:
	if not dialogIsTyping:
		if nextText != "":
			Events.emit_signal("hud_dialog_show", nextName, nextNameColor, nextText, true, nextPotrait)
		elif multipage:
			Events.emit_signal("hud_dialogue_hide")

###############################################################################
# Callbacks
###############################################################################

func _on_MusicSlider_value_changed(value):
	$HUDLayer/Display/IngameMenu/Menu/MusicSlider/Percentage.set_text(str(value*10)+"%")
	Events.emit_signal("cfg_music_set_volume", value)


func _on_SoundSlider_value_changed(value):
	$HUDLayer/Display/IngameMenu/Menu/SoundSlider/Percentage.set_text(str(value*10)+"%")
	Events.emit_signal("cfg_sound_set_volume", value)



func _on_ButtonQuit_button_up():
	Events.emit_signal("menu_back")
	Global.newGameState()

func updateSlotInfo(id):
	selectedSave = id
	var text
	
	if saveFiles[id].state:
		text = "Slot: " + str(id + 1)  + \
			"\n\n" + \
			"Date:" + Global.getDateTimeStringFromUnixTime(saveFiles[id].date) + "\n" +\
			"Level:" + str(saveFiles[id].level)
	else:
		text = "Saving to new slot."
	$HUDLayer/Display/SaveGame/Menu/SaveText.text = text

func _on_ButtonReturn_button_up():
	$HUDLayer/Display/IngameMenu.hide()
	onHideSave()
	if not inMissionBriefing:
		get_tree().paused = false
	else:
		$HUDLayer/Display/MissionBriefing/StartMissionButton.grab_focus()

func _on_ButtonSave_button_up():
	save(selectedSave)

func _on_ButtonSave1_button_up():
	updateSlotInfo(0)


func _on_ButtonSave2_button_up():
	updateSlotInfo(1)


func _on_ButtonSave3_button_up():
	updateSlotInfo(2)


func _on_StartMissionButton_button_up():
	$HUDLayer/Display/MissionBriefing.hide()
	Events.emit_signal("hud_mission_briefing_exited")
	inMissionBriefing = false
	
	$HUDLayer/LevelFade/AnimationPlayer.play("fade_out")

	#hmm duno if this is right place to go but need to trigger update taser text 
	if Types.UpgradeTypes.Taser_Extended_Battery in Global.gameState.playerUpgrades:
		taserUpdate(5)




func _on_DebugPromo_button_up():
	if Global.DEBUG:
		debugHudToggle(null) 
		debugShaderToggle(null)
		if $HUDLayer/PromoShot/PromoSteam.visible:
			$HUDLayer/PromoShot/PromoSteam.hide()
			$HUDLayer/PromoShot/PromoTitel.hide()
		else:
			$HUDLayer/PromoShot/PromoSteam.show()
			$HUDLayer/PromoShot/PromoTitel.show()
	



func hookSetup():
	# External Signals

	Events.connect("level_hint", self, "onLevelHint")
	Events.connect("minigame_entered", self, "onMinigameEntered")
	Events.connect("minigame_exited", self, "onMinigameExited")
	
	Events.connect("hud_note_show", self, "showNote")
	Events.connect("hud_dialog_show", self, "showDialog")
	Events.connect("hud_upgrade_window_show", self, "showUpgrade")
	Events.connect("hud_save_window_show", self, "showSave")
	Events.connect("hud_save_window_exited", self, "onHideSave")


	Events.connect("hud_dialogue_hide", self, "hideDialog")
	Events.connect("hud_mission_briefing", self, "showMissionBriefing")
	Events.connect("hud_mission_progress", self, "showMissionProgress")

	Events.connect("hud_game_over", self, "showGameOverNotification")
	Events.connect("hud_game_hint", self, "showGameHintNotification")

	Events.connect("hud_photo_flash", self, "photoFlash")
	Events.connect("no_branch_option_pressed", self, "onNoBranchOptionPressed")



	# Signal from Nodes
	for node in $HUDLayer/Display/Upgrades/Grid.get_children():
		node.connect("Upgrade_Button_Pressed", self, "upgradeSelect")

	dialogTypeTimer.connect("timeout", self, "onDialogTypeTimerTimeout")

func onMinigameEntered(type) -> void:
	inMinigame = true

func onMinigameExited(result) -> void:
	inMinigame = false


