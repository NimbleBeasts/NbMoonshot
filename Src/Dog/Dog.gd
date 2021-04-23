class_name Dog
extends KinematicBody2D

export var audioSuspectDistance: int = 50
export var speed: int = 25
export var detectDistance: int = 50
export (Types.DogStates) var startingState: int = Types.DogStates.Roaming
export var playerSuspectDistance: int = 30
export var playerDetectDistance: int = 16
export var fallAsleepTimer: int = 10
export var sleepDurationTimer: int = 10


var state: int
var direction: Vector2
var velocity: Vector2
var suspiciousPosition: Vector2
var player: Player = Global.player
var isMovingToPlayer: bool
var playerInLOS: bool
var barkAfterAngry: bool = false

onready var pathLine: PathLine = get_node("PathLine")
onready var losArea: Area2D = $Flippable/LOSArea
onready var animPlayer: AnimationPlayer = $AnimationPlayer
onready var losRay: RayCast2D = $Flippable/LOSRay


func _ready() -> void:
	setState(startingState)

	$SleepTimer.one_shot = true
	$RoamTimer.one_shot = true
	$DetectionDelay.one_shot = true
	$BarkTimer.one_shot = true
	
	$SleepTimer.wait_time = fallAsleepTimer
	$RoamTimer.wait_time = sleepDurationTimer

	animPlayer.connect("animation_finished", self, "onAnimationFinished")
	$BarkTimer.connect("timeout", self, "onBarkTimeout")
	$DetectionDelay.connect("timeout", self, "onDetectionDelayTimeout")
	$RoamTimer.connect("timeout", self, "onRoamTimeout")
	$SleepTimer.connect("timeout", self, "onSleepTimeout")
	losArea.connect("body_entered", self, "onLOSBodyEntered")
	losArea.connect("body_exited", self, "onLOSBodyExited")
	pathLine.connect("next_point_reached", self, "onPathLineNextPointReached")
	$Flippable/DogArea.connect("body_entered", self, "onDogBodyEntered")
	Events.connect("audio_level_changed", self, "onAudioLevelChanged")
	losRay.set_deferred("enabled", false)

	if playerInLOS and losRayIsCollidingWith(player):
		setState(Types.DogStates.Angry)
		losRay.set_deferred("enabled", false)


func _process(delta: float) -> void:
	velocity = direction * speed
	velocity = move_and_slide(velocity)
	if state != Types.DogStates.Sleeping:
		detectPlayerIfClose()

	if direction.x != 0:
		$Flippable.scale.x = -direction.normalized().x
		$AnimationPlayer.play("walk")
	elif state == Types.DogStates.Roaming:
		$AnimationPlayer.play("look_around")
	
func losRayIsCollidingWith(obj: Node) -> bool:
	return losRay.is_colliding() and losRay.get_collider() == obj
		


func onAudioLevelChanged(newLevel, audioPosition, emitter) -> void:
	if emitter.is_in_group("Snack"):
		suspiciousPosition = emitter.global_position
		setState(Types.DogStates.MovingToSnack)
		return

	if state == Types.DogStates.Detection:
		return

	match newLevel:
		Types.AudioLevels.LoudNoise:
			if audioPosition.distance_to(global_position) < audioSuspectDistance:
				var yDistance = abs(audioPosition.y - global_position.y)
				if yDistance > 20:
					return
				suspiciousPosition = audioPosition
				setState(Types.DogStates.Suspicious)
				losArea.set_deferred("monitoring", true)


func setState(newState: int) -> void:
	if state != newState:
		state = newState
		call("state" + Types.DogStates.keys()[state] + "Enter")


# entering functions for states
func stateAngryEnter() -> void:
	$SleepTimer.stop()
	$RoamTimer.stop()
	pathLine.stopAllMovement()
	Global.startTimerOnce($DetectionDelay)
	flipTowards(player.global_position)
	animPlayer.play("grr")
	yield(get_tree().create_timer(0.8), "timeout")
	Events.emit_signal("play_sound", "dog_growl", 1.0, Global.calcAudioPosition(global_position))
	

func stateMovingToSnackEnter() -> void:
	animPlayer.play("walk")
	$Notifier.popup(Types.NotifierTypes.Question)
	pathLine.moveToPoint(suspiciousPosition)
	losArea.set_deferred("monitoring", false)


func stateSleepingEnter() -> void:
	if fallAsleepTimer > 0:
		losArea.position = Vector2(0,0)
		losArea.scale = Vector2(1,1)
		animPlayer.play("laying_down")
		Global.startTimerOnce($RoamTimer)
		pathLine.stopAllMovement()
		losArea.set_deferred("monitoring", false)
	else:
		setState(Types.DogStates.Roaming)


func stateRoamingEnter() -> void:
	$Notifier.remove()
	losArea.set_deferred("monitoring", true)
	pathLine.startNormalMovement()
	Global.startTimerOnce($SleepTimer)


func stateSuspiciousEnter() -> void:
	losArea.position = Vector2(0,0)
	losArea.scale = Vector2(1,1)
	losArea.set_deferred("monitoring", true)
	pathLine.moveToPoint(suspiciousPosition)
	isMovingToPlayer = true
	$Notifier.popup(Types.NotifierTypes.Question)


func stateDetectionEnter() -> void:
	losArea.position = Vector2(0,0)
	losArea.scale = Vector2(1,1)
	$SleepTimer.stop()
	$RoamTimer.stop()
	$DetectionDelay.stop()
	Events.emit_signal("player_detected", Types.DetectionLevels.Sure)
	pathLine.stopAllMovement()
	$Notifier.popup(Types.NotifierTypes.Exclamation)
	losArea.set_deferred("monitoring", false)
	animPlayer.play("alarm")
	Global.startTimerOnce($BarkTimer)
	Events.emit_signal("play_sound", "dog_bark", 1.0, Global.calcAudioPosition(global_position))


func stateEatingEnter() -> void:
	$Notifier.remove()
	losArea.position = Vector2(0,0)
	losArea.scale = Vector2(1,1)
	losArea.set_deferred("monitoring", false)
	pathLine.stopAllMovement()
	animPlayer.play("eat")
	$DetectionDelay.stop()
	$SleepTimer.stop()
	$RoamTimer.stop()
	$BarkTimer.stop()


func feed() -> void:
	setState(Types.DogStates.Eating)


func onPathLineNextPointReached() -> void:
	if state == Types.DogStates.Detection:
		return
	if pathLine.stopOnReachedPoint:
		$AnimationPlayer.play("look_around")
	if state == Types.DogStates.MovingToSnack:
		setState(Types.DogStates.Roaming)
	if isMovingToPlayer and not playerInLOS:
		setState(Types.DogStates.Roaming)
		isMovingToPlayer = false


func onAnimationFinished(animName: String) -> void:
	if animName == "get_up":
		setState(Types.DogStates.Roaming)


func onDogBodyEntered(body: Node) -> void:
	if body.is_in_group("Snack"):
		feed()
		body.queue_free()
	elif body.is_in_group("DoorWall"):
		var door = body.get_parent()
		if door.lockLevel == Types.DoorLockType.open:
			door.interact(true, global_position)
		else:
			$Notifier.remove()
			pathLine.moveToStartingPoint()


func onLOSBodyEntered(body: Node) -> void:
	if body.is_in_group("Player"):
		playerInLOS = true
		losRay.set_deferred("enabled", true)

			
func onLOSBodyExited(body: Node) -> void:
	if body.is_in_group("Player"):
		playerInLOS = false
		losRay.set_deferred("enabled", false)
		if $DetectionDelay.time_left > $DetectionDelay.wait_time - 0.3:
			$DetectionDelay.stop()
			setState(Types.DogStates.Roaming)
		

func onSleepTimeout() -> void:
	setState(Types.DogStates.Sleeping)


func onRoamTimeout() -> void:
	animPlayer.play("get_up")


func onDetectionDelayTimeout() -> void:
	setState(Types.DogStates.Detection)


func onBarkTimeout() -> void:
	setState(Types.DogStates.Roaming)


func flipTowards(towards: Vector2) -> void:
	if towards.x > global_position.x:
		$Flippable.scale.x = -1
	elif towards.x < global_position.x:
		$Flippable.scale.x = 1


func detectPlayerIfClose() -> void:
	if player.global_position.distance_to(global_position) < playerSuspectDistance and state != Types.GuardStates.Stunned:
		if player.state != Types.PlayerStates.WallDodge and losRayIsCollidingWith(player):
				pathLine.moveToPoint(player.global_position)
				if not $Notifier.isShowing:
					$Notifier.popup(Types.NotifierTypes.Question)
				if player.global_position.distance_to(global_position) < playerDetectDistance and losRayIsCollidingWith(player):
					setState(Types.DogStates.Detection)
