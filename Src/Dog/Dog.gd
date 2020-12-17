class_name Dog
extends KinematicBody2D

export var audioSuspectDistance: int = 50
export var speed: int = 25
export var detectDistance: int = 50
export (Types.DogStates) var startingState: int = Types.DogStates.Roaming

var state: int
var direction: Vector2
var velocity: Vector2
var suspiciousPosition: Vector2
var player: Player
var isMovingToPlayer: bool
var playerInLOS: bool
var barkAfterAngry: bool = false
var playerEntered: bool = false
var isFed: bool = false

onready var pathLine: PathLine = get_node("DogPathLine")
onready var losArea: Area2D = $Flippable/LOSArea
onready var animPlayer: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	setState(startingState)

	$SleepTimer.one_shot = true
	$RoamTimer.one_shot = true
	$DetectionDelay.one_shot = true
	$BarkTimer.one_shot = true

	$BarkTimer.connect("timeout", self, "onBarkTimeout")
	$DetectionDelay.connect("timeout", self, "onDetectionDelayTimeout")
	$RoamTimer.connect("timeout", self, "onRoamTimeout")
	$SleepTimer.connect("timeout", self, "onSleepTimeout")
	losArea.connect("body_entered", self, "onLOSBodyEntered")
	losArea.connect("body_exited", self, "onLOSBodyExited")
	$Flippable/DogArea.connect("body_entered", self, "onDogBodyEntered")
	$Flippable/DogArea.connect("body_exited", self, "onDogBodyExited")
	Events.connect("audio_level_changed", self, "onAudioLevelChanged")


func _process(delta: float) -> void:
	velocity = direction * speed
	velocity = move_and_slide(velocity)

	if direction.x != 0:
		$Flippable.scale.x = -direction.normalized().x
		$AnimationPlayer.play("walk")
	elif state == Types.DogStates.Roaming:
		$AnimationPlayer.play("look_around")
		

func onAudioLevelChanged(newLevel, audioPosition) -> void:
	if state == Types.DogStates.Detection or state == Types.DogStates.Eating:
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
	$Flippable.scale.x = -global_position.direction_to(player.global_position).x
	animPlayer.play("grr")


func stateSleepingEnter() -> void:
	losArea.position = Vector2(0,0)
	losArea.scale = Vector2(1,1)
	animPlayer.play("laying_down")
	Global.startTimerOnce($RoamTimer)
	pathLine.stopAllMovement()
	losArea.set_deferred("monitoring", false)


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


func stateEatingEnter() -> void:
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
	if isFed:
		return
		
	setState(Types.DogStates.Eating)
	isFed = true


func onPathLineNextPointReached() -> void:
	if isMovingToPlayer and not playerInLOS and state != Types.DogStates.Detection:
		setState(Types.DogStates.Roaming)
		isMovingToPlayer = false


func onDogBodyEntered(body: Node) -> void:
	if body.is_in_group("Player"):
		playerEntered = true


func onDogBodyExited(body: Node) -> void:
	if body.is_in_group("Player"):
		playerEntered = false


func onLOSBodyEntered(body: Node) -> void:
	if body.is_in_group("Player"):
		player = body
		playerInLOS = true
		setState(Types.DogStates.Angry)

			
func onLOSBodyExited(body: Node) -> void:
	if body.is_in_group("Player"):
		playerInLOS = false
		if $DetectionDelay.time_left > $DetectionDelay.wait_time - 0.3:
			$DetectionDelay.stop()
			setState(Types.DogStates.Roaming)
			print("escape out of dog sight")
		

func onSleepTimeout() -> void:
	setState(Types.DogStates.Sleeping)


func onRoamTimeout() -> void:
	setState(Types.DogStates.Roaming)
	animPlayer.play("get_up")


func onDetectionDelayTimeout() -> void:
	setState(Types.DogStates.Detection)


func onBarkTimeout() -> void:
	setState(Types.DogStates.Roaming)
