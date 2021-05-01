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

var laserSprite = preload("res://Assets/Laser/LaserDetector.png")
var laserPath = preload("res://Assets/Laser/Path.png")

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
		tweenEndPositions[0] = Vector2(0, 0)
		match moveDirection:
			Types.Direction.Left:
				tweenEndPositions[1] = Vector2(-moveDistance * 8, 0)
			Types.Direction.Right:
				tweenEndPositions[1] = Vector2(moveDistance * 8, 0)
			Types.Direction.Top:
				tweenEndPositions[1] = Vector2(moveDistance * 8, 0)
			_:
				tweenEndPositions[1] = Vector2(-moveDistance * 8, 0)
	
	#print(tweenEndPositions)

	# Bottom Node
	$BeamNode/Bottom.position = Vector2(0, 8) * heigth
	
	# Collision Shape
	var shape = RectangleShape2D.new()
	shape.extents = Vector2(0, 4) * heigth + Vector2(2, 0)
	$BeamNode/Area2D/CollisionShape2D.set_shape(shape)
	$BeamNode/Area2D/CollisionShape2D.position = Vector2(0, 8) * (float(heigth)/2) + Vector2(4, 0)

	# Laser Beam Node
	for i in range(heigth):
		var sprite = Sprite.new()
		sprite.texture = laserSprite
		sprite.position = Vector2(0, 8) * i + Vector2(4, 4)
		sprite.z_index = 51
		$BeamNode/LaserBeam.add_child(sprite)

	if not isStatic:
		# Laser movement path
		for i in range(moveDistance + 1):
			var spriteTop = Sprite.new()
			spriteTop.texture = laserPath
			spriteTop.position = Vector2(8,0) * i + Vector2(4, 2)
			spriteTop.z_index = 51
			self.add_child(spriteTop)

			var spriteBottom = Sprite.new()
			spriteBottom.texture = laserPath
			spriteBottom.position = Vector2(8,0) * i + Vector2(4, heigth * 8 - 1)
			spriteBottom.z_index = 51
			self.add_child(spriteBottom)
		
	$OffTimer.wait_time = standbyTimerAfterDetection

	if not isStatic and not Engine.editor_hint:
		runTween()
	
	if isFlickering:
		$FlickerTimer.start()
	
	if not isHorizontal:
		self.rotation_degrees = -90


func runTween():
	$MotionTween.interpolate_property($BeamNode, "position", tweenEndPositions[0], tweenEndPositions[1], moveDistance * moveSpeed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
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
		$BeamNode/LaserBeam.hide()
		$OffTimer.start(standbyTimerAfterDetection) # Standby Timer


func flickerOff() -> void:
	detectorState = DetectorStateType.Off
	$FlickerTimer.stop() # stop flickering when off 
	$BeamNode/LaserBeam.hide()
	$OffTimer.start(0.2) 


func _on_OffTimer_timeout():
	detectorState = DetectorStateType.Running
	$BeamNode/LaserBeam.show()
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
	$LaserDetect.play()
	

func _on_FlickerTimer_timeout():
	currentIndex += 1

	if currentIndex >= flickerSequence.length():
		currentIndex = 0

	var desiredFrameState = int(flickerSequence[currentIndex])
	if desiredFrameState != detectorState:
		detectorState = desiredFrameState
	
	if detectorState == DetectorStateType.Off:
		$BeamNode/Top.frame = 2
		$BeamNode/Bottom.frame = 2
		$BeamNode/LaserBeam.hide()
	elif detectorState == DetectorStateType.Running:
		$BeamNode/LaserBeam.show()
		$BeamNode/Top.frame = 0
		$BeamNode/Bottom.frame = 0
		$MotionTween.resume_all()


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
	$BeamNode/Top.frame = 2
	$BeamNode/Bottom.frame = 2
	set_physics_process(true)
	$BeamNode/LaserBeam.show() # is this correct? 
	$OffTimer.start(0.001)
	if isFlickering:
		$FlickerTimer.start()
	$MotionTween.playback_speed = 1
	$AnimationPlayer.play()


func deactivate() -> void:
	$BeamNode/Top.frame = 2
	$BeamNode/Bottom.frame = 2
	set_physics_process(false)
	$BeamNode/LaserBeam.hide() # is this correct? 
	$OffTimer.stop()
	$DetectionDelay.stop()
	$FlickerTimer.stop()
	#$MotionTween.stop_all()
	$MotionTween.playback_speed = 0
	$AnimationPlayer.stop()
