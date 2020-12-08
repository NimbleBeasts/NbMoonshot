class_name Guard
extends KinematicBody2D


export var speed: int = 50
export var direction_change_time: float = 2
export var starting_direction: Vector2
export var time_to_sure_detection: float = 1.5
export var stun_duration: float = 10
export var audio_suspect_distance: int = 150
export var normal_time_to_alarm: float = 1.5
export var extended_time_to_alarm: float = 3.5
export var playerSuspectDistance: int = 30
export var playerDetectDistance: int = 16

var velocity: Vector2
var direction: Vector2
var state: int = Types.GuardStates.Wander # Types.GuardStates
var player_in_los: bool = false
var player_detected: bool = false
var playerLastSeenPosition: Vector2

var guard_normal_texture: Texture = preload("res://Assets/Guards/Guard.png")
var guard_green_texture: Texture = preload("res://Assets/Guards/GuardGreen.png")
var guardPathLine
var playerVisibility: int 
var guardInSight: Guard

onready var los_area: Area2D = $Flippable/LineOfSight
onready var goBackToNormalTimer: Timer = $GoBackToNormalTimer
onready var losRay: RayCast2D = $Flippable/LOSRay
onready var player = Global.player

func _ready() -> void:
	global_position.y -= 2 
	goBackToNormalTimer.connect("timeout", self, "onGoBackToNormalTimeout")
	add_to_group("Upgradable")
	do_upgrade_stuff()
	losRay.set_deferred("enabled", false)

	# sets sprite texture on level type
	match Global.game_manager.getCurrentLevel().level_type:
		Types.LevelTypes.Western:
			$Flippable/Sprite.texture = guard_normal_texture
		Types.LevelTypes.Eastern:
			$Flippable/Sprite.texture = guard_green_texture 

	# sets the wait_time to the exported variable
	$SureDetectionTimer.wait_time = time_to_sure_detection

	direction.x = 0
	guardPathLine = get_node("GuardPathLine")

	Events.connect("audio_level_changed", self, "_on_audio_level_changed")
	Events.connect("visible_level_changed", self, "onVisibleLevelChanged")
	#warning-ignore:return_value_discarded


func _process(_delta: float) -> void:
	velocity = direction * speed
	velocity = move_and_slide(velocity)
	update_flip()
	if state == Types.GuardStates.Wander or state == Types.GuardStates.Suspect:
		detectPlayerIfClose()


	if state != Types.GuardStates.Stunned and state != Types.GuardStates.PlayerDetected:
		if not velocity.is_equal_approx(Vector2.ZERO):
			$AnimationPlayer.play("walk")
		else:
			$AnimationPlayer.play("idle")

	if guardInSight:
		if guardInSight.state == Types.GuardStates.Stunned:
			set_state(Types.GuardStates.PlayerDetected)
			

func _physics_process(delta: float) -> void:
	if player_in_los:
		if losRayIsCollidingWithPlayer(): # ray checking
			playerDetectLOS()


func losRayIsCollidingWithPlayer() -> bool:
	return losRay.is_colliding() and losRay.get_collider().is_in_group("Player")


func detectPlayerIfClose() -> void:
	if player.global_position.distance_to(global_position) < playerSuspectDistance and state != Types.GuardStates.Stunned:
		if player.state != Types.PlayerStates.WallDodge and losRayIsCollidingWithPlayer() and not player_detected:
				guardPathLine.moveToPoint(player.global_position)
				if not $Notifier.isShowing:
					$Notifier.popup(Types.NotifierTypes.Question)
					Events.emit_signal("play_sound", "suspicious")
				if player.global_position.distance_to(global_position) < playerDetectDistance:
					set_state(Types.GuardStates.PlayerDetected)


# stun function.
func stun(duration: float) -> void:
	direction = Vector2(0,0)
	set_state(Types.GuardStates.Stunned)
	set_process(false)
	set_physics_process(false)
	$Flippable/LineOfSight/CollisionPolygon2D.set_deferred("disabled", true)
	player_in_los = false
	$AnimationPlayer.play("tasered")
	# timer stuff
	$StunDurationTimer.start(duration)
	$SureDetectionTimer.stop()
	$Notifier.remove()
	player_detected = false


func unstun() -> void:
	$AnimationPlayer.play("stand_up")
	$Flippable/LineOfSight/CollisionPolygon2D.set_deferred("disabled", false)
	$Notifier.remove()
	set_process(true)
	set_physics_process(true)

	
func playerDetectLOS() -> void:
	if state != Types.GuardStates.Stunned:
		match playerVisibility:
			Types.LightLevels.FullLight:
				set_state(Types.GuardStates.PlayerDetected)
				player_in_los = false
				losRay.set_deferred("enabled", false)
			Types.LightLevels.BarelyVisible:
				if not player_detected: # only sets to suspect if hasn't detected player before
					set_state(Types.GuardStates.Suspect)
			Types.LightLevels.Dark:
				if not player_detected: # only sets to wander if hasn't detected player before
					set_state(Types.GuardStates.Wander)

					
func _on_LineOfSight_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
			losRay.set_deferred("enabled", true)
			if state != Types.GuardStates.Stunned:
				player_in_los = true		
	elif body.is_in_group("Guard"):
		guardInSight = body
	

func _on_LineOfSight_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		player_in_los = false
		losRay.set_deferred("enabled", false)
	elif body.is_in_group("Guard") and guardInSight == body:
		guardInSight = null
	

# this gets started when this guard's state changes to PlayerDetected
# on timeout, meaning if not stunned within this time, the detection level of player gets to Sure
func _on_SureDetectionTimer_timeout() -> void:
	$AnimationPlayer.play("alarm")
	set_process(false)
	set_physics_process(false)
	Events.emit_signal("player_detected", Types.DetectionLevels.Sure)
	Events.emit_signal("play_sound", "alarm")

	
func _on_StunDurationTimer_timeout() -> void:
	unstun()


# Event Hook: audio level changed. audio_pos is the position where the audio notification happened
func _on_audio_level_changed(audio_level: int, audio_pos: Vector2) -> void:
	match audio_level:
		Types.AudioLevels.LoudNoise:
			if audio_pos.distance_to(global_position) < audio_suspect_distance:
				var yDistance = audio_pos.y - global_position.y 
				if not yDistance > -20 and yDistance < 20:
					return
				if not $Notifier.isShowing:
					$Notifier.popup(Types.NotifierTypes.Question)
				playerLastSeenPosition = audio_pos
				Events.emit_signal("play_sound", "suspicious")
				guardPathLine.moveToPoint(playerLastSeenPosition)
				Global.startTimerOnce(goBackToNormalTimer)

				
# use this function to set state instead of doing directly
func set_state(new_state) -> void:
	if state != new_state:
		state = new_state
		
		# hmmm, i should prob comment this
		match new_state:
			Types.GuardStates.PlayerDetected:
				playerLastSeenPosition = player.global_position
				Global.startTimerOnce($SureDetectionTimer)
				$GoBackToNormalTimer.stop()
				Events.emit_signal("player_detected", Types.DetectionLevels.Possible)
				player_detected = true
				$AnimationPlayer.play("suspicious")
				guardPathLine.stopAllMovement()
			Types.GuardStates.Suspect:
				playerLastSeenPosition = player.global_position
				guardPathLine.stopAllMovement()
				Events.emit_signal("play_sound", "suspicious")
				if not $Notifier.isShowing:
					$Notifier.popup(Types.NotifierTypes.Question)
				guardPathLine.moveToPoint(playerLastSeenPosition)
				Global.startTimerOnce(goBackToNormalTimer)
			Types.GuardStates.Wander:
				$Notifier.remove()
				guardPathLine.startNormalMovement()
			Types.GuardStates.Stunned:
				playerLastSeenPosition = player.global_position
				$Notifier.remove()
				direction = Vector2(0,0)
				guardPathLine.stopAllMovement()


func update_flip() -> void:
	if direction.x != 0:
		$Flippable.scale.x = direction.x


func do_upgrade_stuff() -> void:
	if Types.UpgradeTypes.Distraction in Global.gameState.playerUpgrades:
		time_to_sure_detection = extended_time_to_alarm
	else:
		time_to_sure_detection = normal_time_to_alarm


func _on_AnimationPlayer_animation_started(anim_name):
	if anim_name == "suspicious":
		$Notifier.popup(Types.NotifierTypes.Exclamation)


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"suspicious":
			$Notifier.remove()
		"alarm":
			pass
		"stand_up":
			# TODO: Make a seperate state for this
			guardPathLine.stopAllMovement()
			Events.emit_signal("play_sound", "suspicious")
			if not $Notifier.isShowing:
				$Notifier.popup(Types.NotifierTypes.Question)
			Global.startTimerOnce(goBackToNormalTimer)


func onGoBackToNormalTimeout() -> void:
	set_state(Types.GuardStates.Wander)
	$Notifier.remove()


func onVisibleLevelChanged(newLevel: int) -> void:
	playerVisibility = newLevel
