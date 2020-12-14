extends KinematicBody2D

export var audioSuspectDistance: int = 50
export var speed: int = 25
export var detectDistance: int = 50
export (Types.DogStates) var startingState: int = Types.DogStates.Roaming
export var sleepTime: float = 10
export var roamTime: float = 10

var state: int
var direction: Vector2
var velocity: Vector2
var suspiciousPosition: Vector2
var player: Player
var isMovingToPlayer: bool
var playerInLOS: bool
var isStunned: bool = false

onready var pathLine: PathLine = get_node("DogPathLine")
onready var losArea: Area2D = $Flippable/LOSArea


func _ready() -> void:
	setState(startingState)
	$SleepTimer.wait_time = sleepTime
	$RoamTimer.wait_time = roamTime
	$RoamTimer.connect("timeout", self, "onRoamTimeout")
	$SleepTimer.connect("timeout", self, "onSleepTimeout")
	pathLine.connect("next_point_reached", self, "onPathLineNextPointReached")
	losArea.connect("body_entered", self, "onLOSBodyEntered")
	losArea.connect("body_exited", self, "onLOSBodyExited")
	Events.connect("audio_level_changed", self, "onAudioLevelChanged")


func _process(delta: float) -> void:
	velocity = direction * speed
	velocity = move_and_slide(velocity)
	if direction.x != 0:
		$Flippable.scale.x = direction.x
	if playerInLOS:
		if global_position.distance_to(player.global_position) < detectDistance:
			setState(Types.DogStates.Detection)


func onAudioLevelChanged(newLevel, audioPosition) -> void:
	match newLevel:
		Types.AudioLevels.LoudNoise:
			if audioPosition.distance_to(global_position) < audioSuspectDistance:
				var yDistance = audioPosition.y - global_position.y 
				if yDistance > -20 and yDistance < 20:
					suspiciousPosition = audioPosition
					setState(Types.DogStates.Suspicious)
					losArea.set_deferred("monitoring", true)


func onLOSBodyEntered(body: Node) -> void:
	if body.is_in_group("Player"):
		player = body
		playerInLOS = true
		if state != Types.DogStates.Detection:
			suspiciousPosition = player.global_position
			setState(Types.DogStates.Suspicious)

			
func onLOSBodyExited(body: Node) -> void:
	if body.is_in_group("Player"):
		playerInLOS = false


func setState(newState: int) -> void:
	if state != newState:
		state = newState
		match newState:
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
				print("bark")
			Types.DogStates.Stunned:
				print("dog stunned")
				pathLine.stopAllMovement()


func onPathLineNextPointReached() -> void:
	if isMovingToPlayer and not playerInLOS and state != Types.DogStates.Detection:
		setState(Types.DogStates.Roaming)
		isMovingToPlayer = false


func onSleepTimeout() -> void:
	setState(Types.DogStates.Sleeping)


func onRoamTimeout() -> void:
	setState(Types.DogStates.Roaming)


func stun(_d) -> void:
	setState(Types.DogStates.Stunned)
