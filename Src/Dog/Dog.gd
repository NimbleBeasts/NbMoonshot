class_name Dog
extends KinematicBody2D

export var audioSuspectDistance: int = 50
export var speed: int = 25
export var detectDistance: int = 50
export (Types.DogStates) var startingState: int = Types.DogStates.Roaming
export var sleepTime: float = 10
export var roamTime: float = 10
export var detectionDelayDuration: float = 1.6

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


func _ready() -> void:
	setState(startingState)

	$SleepTimer.wait_time = sleepTime
	$SleepTimer.one_shot = true
	$RoamTimer.wait_time = roamTime
	$RoamTimer.one_shot = true
	$DetectionDelay.wait_time = detectionDelayDuration
	$DetectionDelay.one_shot = true

	$DetectionDelay.connect("timeout", self, "onDetectionDelayTimeout")
	$RoamTimer.connect("timeout", self, "onRoamTimeout")
	$SleepTimer.connect("timeout", self, "onSleepTimeout")
	pathLine.connect("next_point_reached", self, "onPathLineNextPointReached")
	losArea.connect("body_entered", self, "onLOSBodyEntered")
	losArea.connect("body_exited", self, "onLOSBodyExited")
	$Flippable/DogArea.connect("body_entered", self, "onDogBodyEntered")
	$Flippable/DogArea.connect("body_exited", self, "onDogBodyExited")
	Events.connect("audio_level_changed", self, "onAudioLevelChanged")


func _process(delta: float) -> void:
	velocity = direction * speed
	velocity = move_and_slide(velocity)
	if direction.x != 0:
		$Flippable.scale.x = direction.x

	if playerInLOS:
		if $DetectionDelay.wait_time - $DetectionDelay.time_left > 0.3:
			barkAfterAngry = true


func onAudioLevelChanged(newLevel, audioPosition) -> void:
	if state == Types.DogStates.Detection:
		return
	match newLevel:
		Types.AudioLevels.LoudNoise:
			if audioPosition.distance_to(global_position) < audioSuspectDistance:
				var yDistance = audioPosition.y - global_position.y 
				if yDistance > -20 and yDistance < 20:
					suspiciousPosition = audioPosition
					setState(Types.DogStates.Suspicious)
					losArea.set_deferred("monitoring", true)


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
			print("escape out of dog sight")


func setState(newState: int) -> void:
	if state != newState:
		state = newState
		match newState:
			Types.DogStates.Angry:
				pathLine.stopAllMovement()
				print("play angry sound")
				Global.startTimerOnce($DetectionDelay)
			Types.DogStates.Sleeping:
				Global.startTimerOnce($RoamTimer)
				pathLine.stopAllMovement()
				losArea.set_deferred("monitoring", false)
			Types.DogStates.Roaming:
				losArea.set_deferred("monitoring", true)
				pathLine.startNormalMovement()
				Global.startTimerOnce($SleepTimer)
			Types.DogStates.Suspicious:
				losArea.set_deferred("monitoring", true)
				pathLine.moveToPoint(suspiciousPosition)
				isMovingToPlayer = true
				$Notifier.popup(Types.NotifierTypes.Question)
			Types.DogStates.Detection:
				Events.emit_signal("player_detected", Types.DetectionLevels.Sure)
				pathLine.stopAllMovement()
				$Notifier.popup(Types.NotifierTypes.Exclamation)
				losArea.set_deferred("disabled", true)
				print("bark")
			Types.DogStates.Stunned:
				print("dog stunned")
				pathLine.stopAllMovement()
			Types.DogStates.Eating:
				print("eating now :)")


func feed() -> void:
	if isFed:
		return
		
	setState(Types.DogStates.Eating)
	$DetectionDelay.stop()
	isFed = true


func onPathLineNextPointReached() -> void:
	if isMovingToPlayer and not playerInLOS and state != Types.DogStates.Detection:
		setState(Types.DogStates.Roaming)
		isMovingToPlayer = false


func onSleepTimeout() -> void:
	setState(Types.DogStates.Sleeping)


func onRoamTimeout() -> void:
	setState(Types.DogStates.Roaming)


func onDetectionDelayTimeout() -> void:
	setState(Types.DogStates.Detection)


