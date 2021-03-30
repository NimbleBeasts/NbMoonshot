tool
extends Node2D

export(int) var heigth = 7
export(bool) var isStatic = true
export(float) var moveSpeed = 0.5
export(int) var moveDistance = 5
export(Types.Direction) var moveDirection = Types.Direction.Right
export(bool) var isHorizontal = true
export(bool) var isFlickering = false
export(String) var flickerSequence = "1110"
export(float) var standbyTimerAfterDetection = 3.0
export(bool) var startOff = false

export(int) var canToggleTimes = 0 #0 infinite

enum DetectorStateType {Running = 1, Detection = 2, Off = 0}

var laserSprite = preload("res://Assets/Objects/LaserDetector.png")

var tweenEndPositions = [Vector2(), Vector2()]
var playerInArea = null

var detectorState = DetectorStateType.Running
var currentIndex = 0


# Detection progress:
# - Pause Tween
# - Detection Animation 


func _ready():
	setup()
	if startOff:
		deactivate()

func _physics_process(_delta):
	if playerInArea:
		# Player in detection area
		if detectorState == DetectorStateType.Running:
			if (isHorizontal and playerInArea.state != Types.PlayerStates.WallDodge) \
				or (not isHorizontal):
				# Wall dodgine prevents on horizontal scanners, but not on vertical
				if $DetectionDelay.time_left == 0:
					$DetectionDelay.start() # Delay detection for a bit
					detectorState = DetectorStateType.Off
					
					
func setup():
	if not isStatic:
		# Setup end positions
		tweenEndPositions[0] = position
		match moveDirection:
			Types.Direction.Left:
				tweenEndPositions[1] = Vector2(position.x - moveDistance * 8, position.y)
			Types.Direction.Right:
				tweenEndPositions[1] = Vector2(position.x + moveDistance * 8, position.y)
			Types.Direction.Top:
				tweenEndPositions[1] = Vector2(position.x, position.y  - moveDistance * 8)
			_:
				tweenEndPositions[1] = Vector2(position.x, position.y  + moveDistance * 8)

	# Bottom Node
	$Bottom.position = Vector2(0, 8) * heigth
	
	# Collision Shape
	var shape = RectangleShape2D.new()
	shape.extents = Vector2(0, 4) * heigth + Vector2(2, 0)
	$Area2D/CollisionShape2D.set_shape(shape)
	$Area2D/CollisionShape2D.position = Vector2(0, 8) * (float(heigth)/2) + Vector2(4, 0)

	# Laser Beam Node
	for i in range(heigth):
		var sprite = Sprite.new()
		sprite.texture = laserSprite
		sprite.position = Vector2(0, 8) * i + Vector2(4, 4)
		sprite.z_index = 51
		$LaserBeam.add_child(sprite)

	$OffTimer.wait_time = standbyTimerAfterDetection

	if not isStatic and not Engine.editor_hint:
		runTween()
	
	if isFlickering:
		$FlickerTimer.start()
	
	if not isHorizontal:
		self.rotation_degrees = -90


func runTween():
	$MotionTween.interpolate_property(self, "position", position, tweenEndPositions[1], moveDistance * moveSpeed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$MotionTween.start()


func _on_MotionTween_tween_completed(_object, _key):
	tweenEndPositions.invert()
	runTween()


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		playerInArea = body


func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		playerInArea = null


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "detect":
		detectorState = DetectorStateType.Off
		$FlickerTimer.stop() # stop flickering when off 
		$LaserBeam.hide()
		$OffTimer.start(standbyTimerAfterDetection) # Standby Timer


func flickerOff() -> void:
	detectorState = DetectorStateType.Off
	$FlickerTimer.stop() # stop flickering when off 
	$LaserBeam.hide()
	$OffTimer.start(0.2) 


func _on_OffTimer_timeout():
	detectorState = DetectorStateType.Running
	$LaserBeam.show()
	$MotionTween.resume_all()
	$AnimationPlayer.play("idle")
	if isFlickering:
		$FlickerTimer.start() # start flickering again


func _on_DetectionDelay_timeout():
	$MotionTween.stop_all()
	$AnimationPlayer.play("detect")
	$FlickerTimer.stop()
	detectorState = DetectorStateType.Detection
	Events.emit_signal("player_detected", Types.DetectionLevels.Sure)
	Events.emit_signal("play_sound", "laser_detect")
	

func _on_FlickerTimer_timeout():
	currentIndex += 1

	if currentIndex >= flickerSequence.length():
		currentIndex = 0

	var desiredFrameState = int(flickerSequence[currentIndex])
	if desiredFrameState != detectorState:
		detectorState = desiredFrameState
		
	if detectorState == DetectorStateType.Running:
		_on_OffTimer_timeout() # Switching to On
	else:
		$Top.frame = 2
		$Bottom.frame = 2
		# _on_AnimationPlayer_animation_finished("detect") # Switching to off	
		flickerOff()

func toggleState():
	if canToggleTimes != 1:
		canToggleTimes = canToggleTimes - 1
	if canToggleTimes == 1:
		return
	
	if is_physics_processing():
		deactivate()
	else:
		activate()

func activate():
	$Top.frame = 2
	$Bottom.frame = 2
	set_physics_process(true)
	$LaserBeam.show() # is this correct? 
	$OffTimer.start(0.001)
	if isFlickering:
		$FlickerTimer.start()
	$MotionTween.playback_speed = 1
	$AnimationPlayer.play()


func deactivate() -> void:
	$Top.frame = 2
	$Bottom.frame = 2
	set_physics_process(false)
	$LaserBeam.hide() # is this correct? 
	$OffTimer.stop()
	$DetectionDelay.stop()
	$FlickerTimer.stop()
	#$MotionTween.stop_all()
	$MotionTween.playback_speed = 0
	$AnimationPlayer.stop()
