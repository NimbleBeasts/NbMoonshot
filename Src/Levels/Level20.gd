extends "res://Src/Levels/BaseLevel.gd"

var timerStarted = false
var time = 60.0
var bombDefused = false
var itsOverLetMeQuit = false

func _ready():
	$AdditionalHUD/Overlay/BombTimer.hide()
	$NPCS/Secretary.connect("npc_dialogue_finished", self, "dialogue_finished")

	$LevelObjects/Objects/TNT/WireCutSpawner.connect("minigame_succeeded", self, "wireCutSuccess")


# Intro functions
func dialogue_finished():
	$DialogueBlocker.position = Vector2(-100,-100)
	$NPCS/Secretary/WalkAnimationPlayer.play("walk")
	Events.emit_signal("player_block_movement")

func _on_WalkAnimationPlayer_animation_finished(anim_name):
	Events.emit_signal("player_unblock_movement")
	$AdditionalHUD/Overlay/BombTimer.show()
	timerStarted = true



func _physics_process(delta):
	if timerStarted:
		time -= delta
		
		if time <= 0:
			time = 0
			timerStarted = false
			missionEnd(Types.MissionEnd.Timeout)
		
		updateTimer()
		$LevelObjects/Objects/TNT/WireCutSpawner.countdownTime = time
		
		
	if itsOverLetMeQuit:
		# Lazy workaround. some layer is preventing us from clicking the exit button. I guess its HUD but fuck it
		if Input.is_action_just_pressed("interact"):
			yield(get_tree().create_timer(0.1), "timeout")
			_on_ButtonQuit_button_up()
		

func wireCutSuccess():
	timerStarted = false
	bombDefused = true
	missionEnd(Types.MissionEnd.Defused)

func updateTimer():
	var timerValue = int(time * 100)
	$AdditionalHUD/Overlay/BombTimer/dig6.frame = max(0, timerValue % 10) #least significant digit 
	$AdditionalHUD/Overlay/BombTimer/dig5.frame = max(0, (timerValue / 10) % 10)
	$AdditionalHUD/Overlay/BombTimer/dig4.frame = max(0, (timerValue / 100) % 10)
	$AdditionalHUD/Overlay/BombTimer/dig3.frame = max(0, (timerValue / 1000) % 10)





func _on_ExitArea_body_entered(body):
	if timerStarted:
		missionEnd(Types.MissionEnd.Escaped)


func missionEnd(type):
	$AdditionalHUD.layer = 21 # Draw over HUD
	Events.emit_signal("player_block_movement")
	if type == Types.MissionEnd.Timeout:
		$AdditionalHUD/Overlay/Explosion.show()
		$AdditionalHUD/Overlay/Explosion/AnimationPlayer.play("explosion")
	else:
		$AdditionalHUD/Overlay/BlackOut.show()
		$AdditionalHUD/Overlay/BlackOut/AnimationPlayer.play("fade")
		Events.emit_signal("play_music", Types.MusicType.winlevel)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade":
		SteamWorks.setAchievement("STEAM_ACH_12") #escape alive
		if bombDefused:
			$AdditionalHUD/Overlay/Outro/FlyByText.bbcode_text = "[center]" + tr("OUTRO_DEFUSED") + "[/center]"
		else:
			$AdditionalHUD/Overlay/Outro/FlyByText.bbcode_text = "[center]" + tr("OUTRO_ESCAPED") + "[/center]"
		
		$AdditionalHUD/Overlay/Outro.show()
		$AdditionalHUD/Overlay/Outro/FlyByText/FlyByAnimationPlayer.play("flyby")
		get_tree().paused = true
	elif anim_name == "explosion":
		yield(get_tree().create_timer(1), "timeout")
		$Player.onGameOver()



func _on_FlyByAnimationPlayer_animation_finished(anim_name):
	$AdditionalHUD/Overlay/Outro/ButtonQuit.show()
	$AdditionalHUD/Overlay/Outro/ButtonQuit.grab_focus()
	$AdditionalHUD/Overlay/Outro/ButtonQuit.grab_click_focus()
	itsOverLetMeQuit = true
	get_tree().paused = false
	

func _on_ButtonQuit_button_up():
	itsOverLetMeQuit = false
	Events.emit_signal("menu_back")
	if get_tree():
		yield(get_tree().create_timer(0.1), "timeout")
	Global.newGameState()
	
