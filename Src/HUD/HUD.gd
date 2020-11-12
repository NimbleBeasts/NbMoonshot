extends CanvasLayer

enum HoverType {Light, Audio, Web}

var count = 0
var detected_value: int

func _ready():
	detected_value = Global.game_manager.getCurrentLevel().allowed_detections
	$AlarmIndicator/Label.set_text(str(detected_value))
	Events.connect("light_level_changed", self, "updateLightLevel")
	Events.connect("audio_level_changed", self, "updateAudioLevel")
	
	Events.connect("hud_note_show", self, "showNote")
	Events.connect("hud_dialog_show", self, "showDialog")
	
	Events.connect("sure_detection_num_changed", self, "alarmIndication")
	Events.connect("taser_fired", self, "taserUpdate")

func taserUpdate(value):
	$ChargeIndicator.frame = 3 - value
	$ChargeIndicator/Label.set_text(str(value))

func alarmIndication(value):
	detected_value -= 1
	$AlarmIndicator/AlarmAnimation.play("downgrade")
	$AlarmIndicator/Label.set_text(str(detected_value))

	
func showNote(type, text):
	if type == Types.NoteType.Local:
		$Note.texture = preload("res://Assets/HUD/NoteLocal.png")
	else:
		$Note.texture = preload("res://Assets/HUD/Note.png")

	$Note/Text.bbcode_text = str(text)
	$Note.show()


func showDialog(pname: String, nameColor: String, text: String):
	# I think you meant dialog, so I changed this from note
	$Dialog/Text.bbcode_text = "[color="+nameColor+"]"+pname+"[/color]: " + text
	$Dialog.show()


func _physics_process(delta):
	# Hide Note
	if Input.is_action_just_pressed("ui_cancel"):
		if $Note.visible:
			$Note.hide()
			Events.emit_signal("hud_note_exited")
		elif $Dialog.visible:
			$Dialog.hide()
			Events.emit_signal("hud_dialog_exited")
		elif $IngameMenu.visible:
			$IngameMenu.hide()
			get_tree().paused = false
		else:
			$IngameMenu.show()
			get_tree().paused = true



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
	

func updateAudioLevel(newAudioLevel, audio_pos): #TODO: audio_pos needed?
	if newAudioLevel >= 0 and newAudioLevel < Types.AudioLevels.size():
		$AudioIndicator.frame = newAudioLevel
	else:
		print("HUD: Illegal audio level provided")
	
	$AudioIndicator/GoBackToNormal.start()


func _on_GoBackToNormal_timeout() -> void:
	$AudioIndicator.frame = 2


func hover(type):
	match type:
		HoverType.Web:
			$Hovers/Indicator.position = Vector2(12, 0)
			$Hovers/Label.set_text("Status: Web Monetization Plugin.")
		HoverType.Audio:
			$Hovers/Indicator.position = Vector2(43, 0)
			$Hovers/Label.set_text("This is your noise indicator.")
		_: #Light
			$Hovers/Indicator.position = Vector2(72, 0)
			$Hovers/Label.set_text("This is your visibilty indicator.")
	$Hovers.show()



func _on_LightHover_mouse_entered():
	hover(HoverType.Light)


func _on_LightHover_mouse_exited():
	$Hovers.hide()


func _on_AudioHover_mouse_entered():
	hover(HoverType.Audio)


func _on_AudioHover_mouse_exited():
	$Hovers.hide()


func _on_WebHover_mouse_entered():
	hover(HoverType.Web)


func _on_WebHover_mouse_exited():
	$Hovers.hide()


func _on_ButtonQuit_button_up():
	Events.emit_signal("play_sound", "menu_click")
	Events.emit_signal("menu_back")


func _on_ButtonSound_button_up():
	Events.emit_signal("play_sound", "menu_click")
	Events.emit_signal("switch_sound", !Global.userConfig.sound)


func _on_ButtonMusic_button_up():
	Events.emit_signal("play_sound", "menu_click")
	Events.emit_signal("switch_music", !Global.userConfig.music)


func _on_ButtonReturn_button_up():
	Events.emit_signal("play_sound", "menu_click")
	$IngameMenu.hide()
	get_tree().paused = false
