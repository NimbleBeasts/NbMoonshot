extends Node2D

var state: int = Types.CameraStates.Normal
var player_in_fov: bool = false

enum CamDirectionType {Left, Right}

export(CamDirectionType) var camDirection = CamDirectionType.Left
export(bool) var isFixedCam = false


var currentDirection = camDirection

var player
var playerVisibility: int
onready var fovRay: RayCast2D = $FOV/RayCast2D

func _ready():
	Events.connect("visible_level_changed", self, "onVisibleLevelChanged")
	if camDirection == CamDirectionType.Left:
		$AnimationPlayer.current_animation = "idle_left"
		$FOV.scale.x = -1
		currentDirection = CamDirectionType.Right;
	else:
		$AnimationPlayer.current_animation = "idle_right"
		$FOV.scale.x = 1

	
	if not isFixedCam:
		$RotationTimer.start()
		
	#turn off ray on start
	fovRay.set_deferred("enabled", false)


func _process(_delta: float) -> void:
	if state == Types.CameraStates.Rotating or state == Types.CameraStates.Frozen:
		pass
	else:
		figure_out_state()
		
	#rotate ray to player
	if player != null and player_in_fov:
		fovRay.look_at(player.global_position)
		fovRay.rotation_degrees = fovRay.rotation_degrees -90
		
	
func figure_out_state():
	if player_in_fov:
		if fovRayIsCollidingWithPlayer():
			match playerVisibility:
				Types.LightLevels.FullLight:
					set_state(Types.CameraStates.PlayerDetected)
				Types.LightLevels.BarelyVisible:
					set_state(Types.CameraStates.Suspect)
				Types.LightLevels.Dark:
					set_state(Types.CameraStates.Normal)
	else:
		set_state(Types.CameraStates.Normal)
	
func set_state(new_state) -> void:
	
	if state != new_state:
		state = new_state
		
		match state:
			Types.CameraStates.Rotating:
				pass
			Types.CameraStates.Frozen:
				$FrozenTimer.start()
				if not isFixedCam:
					$RotationTimer.stop()
			
			Types.CameraStates.Normal:
				if not $SureDetectionTimer.is_stopped():
					$SureDetectionTimer.stop()
				if not isFixedCam and $RotationTimer.is_stopped():
					$RotationTimer.start()
				#susp to det stop
				if not $SuspToDetTimer.is_stopped():
					$SuspToDetTimer.stop()
					
				if currentDirection == CamDirectionType.Right:
					animation("idle_left")
				else:
					animation("idle_right")
					
			Types.CameraStates.Suspect:	
				if not $SureDetectionTimer.is_stopped():
					$SureDetectionTimer.stop()
				if not isFixedCam and $RotationTimer.is_stopped():
					$RotationTimer.start()
				
				#susp to det start
				if $SuspToDetTimer.is_stopped():
					$SuspToDetTimer.start()
					
				if currentDirection == CamDirectionType.Right:
					animation("susp_left")
					$AnimationPlayer.seek(0,true)
				else:
					animation("susp_right")
					$AnimationPlayer.seek(0,true)
					
			Types.CameraStates.PlayerDetected:
				
				if $SureDetectionTimer.is_stopped():
					$SureDetectionTimer.start()
				
				#susp to det stop
				if not $SuspToDetTimer.is_stopped():
					$SuspToDetTimer.stop()
					
				if currentDirection == CamDirectionType.Right:
					animation("detection_left")
					$AnimationPlayer.seek(0,true)
				else:
					animation("detection_right")
					$AnimationPlayer.seek(0,true)
					
				Events.emit_signal("player_detected", Types.DetectionLevels.Possible)
				$CameraSounds/Beep.play()
				
				set_state(Types.CameraStates.Frozen)

func force_recheck_player():
	var gareas = $FOV.get_overlapping_areas()
	var player_still_in = false
	for g in gareas:
		if g.is_in_group("PlayerArea"):
			player_still_in = true
			break
	return player_still_in

func animation(anim):
	if $AnimationPlayer.current_animation != anim:
		$AnimationPlayer.play(anim)


func _on_FOV_area_entered(area: Area2D) -> void:
	if state != Types.CameraStates.Rotating:
		if area.is_in_group("PlayerArea"):
			player_in_fov = true
			player = area
			fovRay.set_deferred("enabled", true)
	

func _on_FOV_area_exited(area: Area2D) -> void:
	$SuspToDetTimer.stop()
	if state != Types.CameraStates.Rotating:
		if area.is_in_group("PlayerArea"):
			player_in_fov = false
			player = null
			fovRay.set_deferred("enabled", false)

func _on_SureDetectionTimer_timeout() -> void:
	Events.emit_signal("player_detected", Types.DetectionLevels.Sure)
	$CameraSounds/Alarm.play()
	
func _on_FrozenTimer_timeout():
	deactivate()
	#figure_out_state()

func _on_SuspToDetTimer_timeout():
	if state == Types.CameraStates.Suspect:
		set_state(Types.CameraStates.PlayerDetected)

func _on_RotationTimer_timeout():
	set_state(Types.CameraStates.Rotating)
	$FOV/CollisionPolygon2D.set_deferred("disabled", true)
	
	if currentDirection == CamDirectionType.Left:
		$AnimationPlayer.play_backwards("rotation")
		currentDirection = CamDirectionType.Right
	else:
		$AnimationPlayer.play("rotation")
		currentDirection = CamDirectionType.Left


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "rotation":
		# Set new cam direction
		if currentDirection == CamDirectionType.Left:
			camDirection = CamDirectionType.Right
			$FOV.scale.x = 1
			#fovRay.scale.x = 1
		else:
			camDirection = CamDirectionType.Left
			$FOV.scale.x = -1
			#fovRay.scale.x = -1

		$FOV/CollisionPolygon2D.set_deferred("disabled", false)
		player_in_fov = force_recheck_player()
		figure_out_state()
		

func deactivate() -> void:
	set_process(false)
	if currentDirection == CamDirectionType.Right:
		$AnimationPlayer.current_animation = "rotation"
		$AnimationPlayer.seek(0,true)
	else:
		$AnimationPlayer.current_animation = "rotation"
		$AnimationPlayer.seek(0.5,true)
	
	$AnimationPlayer.stop()
	$RotationTimer.stop()
	$SuspToDetTimer.stop()
	$FOV.set_deferred("monitoring", false)
	fovRay.set_deferred("enabled", false)


func fovRayIsCollidingWithPlayer() -> bool:
	return fovRay.is_colliding() and fovRay.get_collider().is_in_group("Player")


func onVisibleLevelChanged(newLevel: int) -> void:
	playerVisibility = newLevel
