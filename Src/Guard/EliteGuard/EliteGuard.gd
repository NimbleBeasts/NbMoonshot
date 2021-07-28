extends KinematicBody2D

export var normalSpeed: int = 20
export var chaseSpeed: int = 40
export var audioSuspectDistance: int = 100

var direction: Vector2
var velocity: Vector2
var speed: int = 20
var foundPlayer: bool
var playerInLOS: bool
var player
var state: int
var suspiciousPosition: Vector2
var lastPosition

onready var losRay: RayCast2D = $Flippable/LOSRay
onready var pathLine: PathLine = get_node_or_null("PathLine")
onready var hasPathLine = pathLine != null

var guard_normal_texture: Texture = preload("res://Assets/Guards/EliteGuard.png")
var guard_green_texture: Texture = preload("res://Assets/Guards/EliteGuardGreen.png")

#enum LevelTypes {USA = 0, USSR = 1, Ustria = 2, Switzerland}
var eliteGuardDetectSounds = [[
	preload("res://Assets/SFX/eliteguard_dontmove.wav"),
	preload("res://Assets/SFX/eliteguard_freeze.wav"),
	preload("res://Assets/SFX/eliteguard_halt.wav")
],[
	preload("res://Assets/SFX/sfx_guard_alarm_soviet1RUS.wav"),
	preload("res://Assets/SFX/sfx_eliteguard_alarm_soviet4RUS.wav"),
	preload("res://Assets/SFX/sfx_eliteguard_alarm_soviet2RUS.wav"),
],[
	preload("res://Assets/SFX/sfx_eliteguard_alarm_soviet3RUS.wav"),
	preload("res://Assets/SFX/sfx_eliteguard_alarm_soviet4RUS.wav"),
	preload("res://Assets/SFX/sfx_eliteguard_alarm_soviet2RUS.wav"),
]]

var nation 

func _ready() -> void:
	stateRoamingEnter()
	speed = normalSpeed
	losRay.set_deferred("enabled", false)
	$Flippable/LineOfSight.connect("body_entered", self, "onLOSBodyEntered")
	$Flippable/TaserRange.connect("body_entered", self, "onTaserRangeBodyEntered")
	$AnimationPlayer.connect("animation_finished", self, "onAnimationFinished")
	$RoamingEnterTimer.connect("timeout", self, "setState", [Types.EliteGuardStates.Roaming])
	$RoamingEnterTimer.one_shot = true

	Events.connect("audio_level_changed", self, "onAudioLevelChanged")


	# sets sprite texture on level type
	nation = Global.game_manager.getCurrentLevel().level_nation_type
	match nation:
		Types.LevelTypes.USSR:
			$Flippable/Sprite.texture = guard_green_texture 
		Types.LevelTypes.Ustria:
			$Flippable/Sprite.texture = guard_green_texture 
		_:
			$Flippable/Sprite.texture = guard_normal_texture

func _physics_process(delta: float) -> void:
	velocity = direction * speed
	velocity = move_and_slide(velocity)
	updateFlip()
	if direction.x != 0:
		$AnimationPlayer.play("walk")
	elif direction.x == 0:
		$AnimationPlayer.play("idle")


func _process(delta: float) -> void:
	if playerInLOS:
		if losRayIsCollidingWithPlayer():
			  setState(Types.EliteGuardStates.MovingToPlayer)
			  set_process(false)       


func setState(newState) -> void:
	if state != newState:
		state = newState
		var funcName = "state" + Types.EliteGuardStates.keys()[state] + "Enter"
		call(funcName)
		

func stateMovingToPlayerEnter() -> void:
	if not foundPlayer:
		$BackToNormal.start()
		lastPosition = global_position
		foundPlayer = true
		if not hasPathLine:
			pathLine = PathLine.new()
			add_child(pathLine)
			hasPathLine = true
		pathLine.moveToPoint(player.global_position)
		speed = chaseSpeed
		Events.emit_signal("player_block_input")
		Events.disconnect("audio_level_changed", self, "onAudioLevelChanged")
		$Notifier.popup(Types.NotifierTypes.Exclamation)
		
		var index = 0
		if nation != Types.LevelTypes.Switzerland:
			index = nation
		playRandomSound($EliteGuard/Detect, eliteGuardDetectSounds[index])


func _on_BackToNormal_timeout():
	$Notifier.remove()
	Events.connect("audio_level_changed", self, "onAudioLevelChanged")
	speed = normalSpeed
	pathLine.moveToPoint(lastPosition)
	foundPlayer = false
	yield(get_tree().create_timer(1.0), "timeout")
	pathLine.startNormalMovement()
	
	

func stateTaseringPlayerEnter() -> void:
	if player:
		flipTowards(player.global_position)
	$EliteGuard/TaserHit.play()
	if hasPathLine:
		pathLine.stopAllMovement()
	set_physics_process(false)
	$AnimationPlayer.play("taser")
	Events.emit_signal("player_block_movement")
	$EliteGuard/TaserDeploy.play()
	$EliteGuard/Taser.play()

func onAudioLevelChanged(newLevel, audioPosition, emitter) -> void:
	match newLevel:
		Types.AudioLevels.LoudNoise:
			if audioPosition.distance_to(global_position) < audioSuspectDistance:
				var yDistance = abs(audioPosition.y - global_position.y)
				if yDistance > 20:
					return
				suspiciousPosition = audioPosition
				setState(Types.EliteGuardStates.Suspicious)


func stateSuspiciousEnter() -> void:
	if hasPathLine:
		pathLine.stopAllMovement()
	flipTowards(suspiciousPosition)
	$Notifier.popup(Types.NotifierTypes.Question)
	$RoamingEnterTimer.start()


func stateRoamingEnter() -> void:
	$Notifier.remove()
	if hasPathLine:
		pathLine.startNormalMovement()


func onTaserRangeBodyEntered(body: Node) -> void:
	if body.is_in_group("Player"):
		player = body
		setState(Types.EliteGuardStates.TaseringPlayer)
	
		
func onLOSBodyEntered(body: Node) -> void:
	if body.is_in_group("Player"):
		losRay.set_deferred("enabled", true)
		playerInLOS = true
		player = body


func onAnimationFinished(animName: String) -> void:
	if animName == "taser":
		if hasPathLine:
			pathLine.stopAllMovement()
		Global.player.stunned()



func losRayIsCollidingWithPlayer() -> bool:
	return losRay.is_colliding() and losRay.get_collider().is_in_group("Player")
	

func updateFlip() -> void:
	if direction.x != 0:
		$Flippable.scale.x = direction.normalized().x


func flipTowards(towards: Vector2) -> void:
	if towards.x > global_position.x:
		$Flippable.scale.x = 1
	elif towards.x < global_position.x:
		$Flippable.scale.x = -1

func playRandomSound(audioPlayer, array: Array) -> void:
	randomize()
	audioPlayer.stream = array[randi() % array.size()]
	audioPlayer.play()


