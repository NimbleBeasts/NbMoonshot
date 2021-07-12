tool
class_name Guard
extends KinematicBody2D

enum Directions {RIGHT, LEFT}
export var normalSpeed: int = 25
export var distractSpeed: int = 37
export var direction_change_time: float = 2
export var time_to_sure_detection: float = 1.5
export var stun_duration: float = 10
export var audio_suspect_distance: int = 150
export var normal_time_to_alarm: float = 1.5
export var extended_time_to_alarm: float = 3.5
export var playerSuspectDistance: int = 30
export var canOpenClosedDoor: bool = false
export var playerDetectDistance: int = 16
export var gravity: int = 800
export (Directions) var startingDirection: int setget setStartingDirection

var velocity: Vector2
var direction: Vector2
var state: int = Types.GuardStates.Wander # Types.GuardStates
var player_in_los: bool = false
var player_detected: bool = false
var playerLastSeenPosition: Vector2
var processAI: bool = false

var guard_normal_texture: Texture = preload("res://Assets/Guards/Guard.png")
var guard_green_texture: Texture = preload("res://Assets/Guards/GuardGreen.png")
var guardPathLine
var distractPathLine
var playerVisibility: int 
var guardInSight: Guard
var isSleeping: bool
var isMovingToPlayer: bool
var isStunned: bool
var applyGravity: bool
var inDistractMode: bool
var delayOver = false

var guardSuspiciousSounds = [
	preload("res://Assets/SFX/guard_suspicious1.wav"),
	preload("res://Assets/SFX/guard_suspicious2.wav"),
	preload("res://Assets/SFX/guard_suspicious3.wav"),
	preload("res://Assets/SFX/guard_suspicious4.wav")
]
var guardAlarmSounds = [
	preload("res://Assets/SFX/guard_alarm1.wav"),
	preload("res://Assets/SFX/guard_alarm2.wav"),
	preload("res://Assets/SFX/guard_alarm3.wav"),
	preload("res://Assets/SFX/guard_alarm4.wav")
]

#warning-ignore:unused_class_variable
onready var los_area: Area2D = $Flippable/LineOfSight #TODO: Not sure if needed
onready var goBackToNormalTimer: Timer = $GoBackToNormalTimer
onready var losRay: RayCast2D = $Flippable/LOSRay
onready var player = Global.player
onready var animPlayer: AnimationPlayer = $AnimationPlayer
#warning-ignore:unused_class_variable
onready var sprite: Sprite = $Flippable/Sprite #TODO: not sure if needed
onready var speed = normalSpeed


func _ready() -> void:
	#warning-ignore:return_value_discarded
	goBackToNormalTimer.connect("timeout", self, "onGoBackToNormalTimeout")
	add_to_group("Upgradable")
	do_upgrade_stuff()
	losRay.set_deferred("enabled", false)

	# sets sprite texture on level type
	match Global.game_manager.getCurrentLevel().level_nation_type:
		Types.LevelTypes.USA:
			$Flippable/Sprite.texture = guard_normal_texture
		Types.LevelTypes.USSR:
			$Flippable/Sprite.texture = guard_green_texture 

	# sets the wait_time to the exported variable
	$SureDetectionTimer.wait_time = time_to_sure_detection

	direction.x = 0
	
	var detectedPath = false
	for child in self.get_children():
		if child is Line2D:
			# Path detected
			if not detectedPath:
				guardPathLine = child
				detectedPath = true
				guardPathLine.connect("next_point_reached", self, "onGuardPathLinePointReached")
			else:
				distractPathLine = child
				distractPathLine.isDistract = true
				distractPathLine.stopAllMovement()

	if guardPathLine == null and distractPathLine == null:
		print("Coudn't find pathline, setting state to idle")
		set_state(Types.GuardStates.Idle)

	#Events.connect("audio_level_changed", self, "_on_audio_level_changed")
	Events.connect("visible_level_changed", self, "onVisibleLevelChanged")
	$Flippable/GuardArea.connect("body_entered", self, "onGuardBodyEntered")
	$Flippable/LineOfSight.connect("body_entered", $CivilianDetect, "onGuardLOSBodyEntered")
	$GroundDetection.connect("apply_gravity", self, "setApplyGravity", ["dummy", true])
	$GroundDetection.connect("body_entered", self, "setApplyGravity", [false])
	#warning-ignore:return_value_discarded
	
	# Random delay - so the guards dont start synchronous
	$StartDelay.wait_time = max(0, float(Global.prng() % 25) / 100 * 10)
	$StartDelay.start()
	

func setStartingDirection(newDirection: int) -> void:
	startingDirection = newDirection
	$Flippable.scale.x = 1 if newDirection == Directions.RIGHT else -1


func _process(delta: float) -> void:
	if Engine.editor_hint:
		return
	
	if not delayOver:
		return
	
	if state == Types.GuardStates.Wander or state == Types.GuardStates.Suspect or state == Types.GuardStates.Idle:
		detectPlayerIfClose()
	if state != Types.GuardStates.Stunned and state != Types.GuardStates.PlayerDetected:
		if not velocity.x == 0:
			$AnimationPlayer.play("walk")
		else:
			$AnimationPlayer.play("idle")

	if guardInSight:
		if guardInSight.state == Types.GuardStates.Stunned:
			set_state(Types.GuardStates.PlayerDetected)


func _physics_process(delta: float) -> void:
	if Engine.editor_hint or not delayOver:
		return

	if player_in_los and processAI:
		if losRayIsCollidingWith(player): # ray checking
			playerDetectLOS()
	
	update_flip()
	if applyGravity:
		velocity.y += gravity * delta
		direction.x = 0
		velocity.x = 0
	else:
		velocity = direction * speed
	velocity = move_and_slide(velocity, Vector2.UP)
	
	
func losRayIsCollidingWith(obj: Node) -> bool:
	return losRay.is_colliding() and losRay.get_collider() == obj


func verifyGuardPathLine() -> void:
	if guardPathLine != null:
		return
	guardPathLine = PathLine.new()
	add_child(guardPathLine)


func detectPlayerIfClose() -> void:
	if player.global_position.distance_to(global_position) < playerSuspectDistance and state != Types.GuardStates.Stunned:
		if player.state != Types.PlayerStates.WallDodge and losRayIsCollidingWith(player) and not player_detected:
				verifyGuardPathLine()
				# if guardPathLine != null:
				guardPathLine.moveToPoint(player.global_position)
				isMovingToPlayer = true
				if not $Notifier.isShowing:
					$Notifier.popup(Types.NotifierTypes.Question)
					playRandomSound($Guard/Suspicious ,guardSuspiciousSounds)
					$GoBackToNormalTimer.start(1)
				if player.global_position.distance_to(global_position) < playerDetectDistance:
					set_state(Types.GuardStates.PlayerDetected)


# stun function.
func stun(duration: float) -> void:
	if state == Types.GuardStates.Stunned:
		return
	isStunned = true
	direction = Vector2(0,0)
	set_state(Types.GuardStates.Stunned)
	$Flippable/LineOfSight/CollisionPolygon2D.set_deferred("disabled", true)
	player_in_los = false
	$AnimationPlayer.play("tasered")
	# timer stuff
	# $StunDurationTimer.start(duration)
	$SureDetectionTimer.stop()
	$Notifier.remove()
	player_detected = false


func unstun() -> void:
	isStunned = false
	$AnimationPlayer.play("stand_up")
	$Flippable/LineOfSight/CollisionPolygon2D.set_deferred("disabled", false)
	$Notifier.remove()
	set_process(true)
#	set_physics_process(true)
	processAI = true
	isSleeping = false

	
func playerDetectLOS() -> void:
	if state != Types.GuardStates.Stunned:
		match playerVisibility:
			Types.LightLevels.FullLight:
				set_state(Types.GuardStates.PlayerDetected)
				player_in_los = false
				losRay.set_deferred("enabled", false)
			Types.LightLevels.BarelyVisible:
				if not player_detected: # only sets to suspect if hasn't detected player before
					playerLastSeenPosition = player.global_position
					set_state(Types.GuardStates.Suspect, true)
			Types.LightLevels.Dark:
				if not player_detected and not isMovingToPlayer and state != Types.GuardStates.Idle and state != Types.GuardStates.Stunned: # only sets to wander if hasn't detected player before
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
#	set_physics_process(false)
	processAI = false
	Events.emit_signal("player_detected", Types.DetectionLevels.Sure)
	playRandomSound($Guard/Alarm, guardAlarmSounds)
	

func _on_StunDurationTimer_timeout() -> void:
	unstun()


# Event Hook: audio level changed. audio_pos is the position where the audio notification happened
func _on_audio_level_changed(audio_level: int, audio_pos: Vector2, _emitter) -> void:
	print("deprecated")
	return
#	if state == Types.GuardStates.Stunned or state == Types.GuardStates.PlayerDetected or \
#	state == Types.GuardStates.BeingDragged:
#		return
#	match audio_level:
#		Types.AudioLevels.LoudNoise:
#			if audio_pos.distance_to(global_position) < audio_suspect_distance:
#				var yDistance = abs(audio_pos.y - global_position.y)
#				if yDistance > 20:
#					return
#				if not $Notifier.isShowing:
#					$Notifier.popup(Types.NotifierTypes.Question)
#				playerLastSeenPosition = audio_pos
#				if state != Types.GuardStates.PlayerDetected:
#					set_state(Types.GuardStates.Suspect, true)

					
# use this function to set state instead of doing directly
func set_state(new_state, forceReEnterIfSameState: bool = false) -> void:
	if state != new_state or forceReEnterIfSameState:
		state = new_state
		match new_state:
			Types.GuardStates.Idle:
				animPlayer.play("idle")
				processAI = true
			Types.GuardStates.PlayerDetected:
				playerLastSeenPosition = player.global_position
				Global.startTimerOnce($SureDetectionTimer)
				$GoBackToNormalTimer.stop()
				Events.emit_signal("player_detected", Types.DetectionLevels.Possible)
				player_detected = true
				$AnimationPlayer.play("suspicious")
				stopMovement()
				$GoBackToNormalAfterDetectTimer.start(5)
				
			Types.GuardStates.Suspect:
				playRandomSound($Guard/Suspicious ,guardSuspiciousSounds)
				if not $Notifier.isShowing:
					$Notifier.popup(Types.NotifierTypes.Question)
				verifyGuardPathLine()
				guardPathLine.moveToPoint(playerLastSeenPosition)
				isMovingToPlayer = true
			Types.GuardStates.Wander:
				$Notifier.remove()
				verifyGuardPathLine()
				guardPathLine.startNormalMovement()
				if direction.x != 0:
					$AnimationPlayer.play("walk")
				isMovingToPlayer = false
			Types.GuardStates.Stunned:
				$GoBackToNormalTimer.stop()
				losRay.set_deferred("monitoring", false)
				$Flippable/GuardArea.set_deferred("monitoring", false)
				$Flippable/LineOfSight.set_deferred("monitoring", false)
				playerLastSeenPosition = player.global_position
				$Notifier.remove()
				direction = Vector2(0,0)
				stopMovement()
				set_process(false)
#				set_physics_process(false)
				processAI = false

func flip(dir):
	$Flippable.scale.x = dir

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
			stopMovement()
			playRandomSound($Guard/Suspicious ,guardSuspiciousSounds)
			if not $Notifier.isShowing:
				$Notifier.popup(Types.NotifierTypes.Question)
			Global.startTimerOnce(goBackToNormalTimer)
		"tasered":
			isSleeping = true


func onGoBackToNormalTimeout() -> void:
	if state != Types.GuardStates.Stunned:
		set_state(Types.GuardStates.Wander, true)
	$Notifier.remove()


func onVisibleLevelChanged(newLevel: int) -> void:
	playerVisibility = newLevel


func onGuardPathLinePointReached() -> void:
	$AnimationPlayer.play("idle")
	if isMovingToPlayer:
		goBackToNormalTimer.wait_time = 3
		stopMovement()
		Global.startTimerOnce(goBackToNormalTimer)
		isMovingToPlayer = false


func onGuardBodyEntered(body: Node) -> void:
	$Label.set_text(str(body))
	if body.is_in_group("DoorWall"):
		var door = body.get_parent()
		if (door.lockLevel == Types.DoorLockType.lockedLevel1 or door.lockLevel == Types.DoorLockType.lockedLevel2 \
			or door.lockLevel == Types.DoorLockType.open) and canOpenClosedDoor:
				door.open()
				door.interact(true, global_position)
					
				#print(str(name) + ": door open")
		else:
			$Notifier.remove()
			guardPathLine.moveToLastPoint()
			#print(str(name) + ": move to starting")


func canDrag() -> bool:
	return state == Types.GuardStates.Stunned and isSleeping and not applyGravity

func isBeingDragged() -> bool:
	return state == Types.GuardStates.BeingDragged

func drag() -> void:
	# Put in foreground
	#TODO: Maybe we change the index when stunned so we have no overlap change
	$Flippable/Sprite.z_index = 51
	$AnimationPlayer.play("carry")
	set_state(Types.GuardStates.BeingDragged)

func stopBeingDragged() -> void:
	# Put background again
	$Flippable/Sprite.z_index = 0
	$AnimationPlayer.play("drop")
	state = Types.GuardStates.Stunned

func setApplyGravity(_dummyargument, to: bool):
	if applyGravity != to:
		applyGravity = to
		
	
func stopMovement():
	if guardPathLine:
		guardPathLine.stopAllMovement()
	if distractPathLine:
		distractPathLine.stopAllMovement()


func distractMode():
	if state != Types.GuardStates.Wander:
		return
	$Notifier.popupForTime(Types.NotifierTypes.Question, 1)
	guardPathLine.stopAllMovement()
	distractPathLine.global_points[0].x = global_position.x
	distractPathLine.startNormalMovement()
	playRandomSound($Guard/Suspicious ,guardSuspiciousSounds)
	inDistractMode = true
	speed = distractSpeed

func normalMode():
	$Notifier.remove()
	distractPathLine.stopAllMovement()
	guardPathLine.startNormalMovement()
	inDistractMode = false
	speed = normalSpeed

func playRandomSound(audioPlayer, array: Array) -> void:
	randomize()
	audioPlayer.stream = array[randi() % array.size()]
	audioPlayer.play()


func _on_AudioListener_invoked(audio_level, audio_pos):
	# print(audio_pos)
	# print(audio_level)
	if state == Types.GuardStates.Stunned or state == Types.GuardStates.PlayerDetected or \
	state == Types.GuardStates.BeingDragged:
		return
	if audio_level < Types.AudioLevels.Silent:
		if not $Notifier.isShowing:
			$Notifier.popup(Types.NotifierTypes.Question)
		playerLastSeenPosition = audio_pos
		if state != Types.GuardStates.PlayerDetected:
			set_state(Types.GuardStates.Suspect, true)


func _on_StartDelay_timeout():
	delayOver = true


func _on_GoBackToNormalAfterDetectTimer_timeout():
	player_detected = false
	processAI = true
	delayOver = true
	
	if guardPathLine == null and distractPathLine == null:
		set_state(Types.GuardStates.Idle)
	else:
		set_state(Types.GuardStates.Wander, true)
	set_process(true)
