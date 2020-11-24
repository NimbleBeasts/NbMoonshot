extends Node2D

var state: int = Types.CameraStates.Normal
var player_in_fov: bool = false

enum CamDirectionType {Left, Right}

export(CamDirectionType) var camDirection = CamDirectionType.Left
export(bool) var isFixedCam = false


var currentDirection = camDirection
var atm_rotating = false

func _ready():
	if camDirection == CamDirectionType.Left:
		animation("idle_left")
		$FOV.scale.x = -1
	else:
		animation("idle_right")
		$FOV.scale.x = 1

	
	if not isFixedCam:
		$RotationTimer.start()


func _process(_delta: float) -> void:
	#dident know if something else is connected
	#to Types.CameraStates so i just added 
	#atm_rotating check insted Types.CameraState.Rotating
	if not atm_rotating:
		if player_in_fov:	
			#print("am in fov")
			match Global.player.visible_level:
				Types.LightLevels.FullLight:
					set_state(Types.CameraStates.PlayerDetected)
					player_in_fov = false
				Types.LightLevels.BarelyVisible:
					set_state(Types.CameraStates.Suspect)
				Types.LightLevels.Dark:
					set_state(Types.CameraStates.Normal)

func _on_FOV_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		player_in_fov = true
	

func _on_FOV_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		player_in_fov = false
		if not isFixedCam and $RotationTimer.is_stopped():
			$RotationTimer.start()
		if state == Types.CameraStates.Suspect:
			set_state(Types.CameraStates.Normal)
			
	

func _on_SureDetectionTimer_timeout() -> void:
	Events.emit_signal("player_detected", Types.DetectionLevels.Sure)
	Events.emit_signal("play_sound", "camera_alarm")

	#now we recheck if player still in fov or he roun out, ofc with some delay
	yield(get_tree().create_timer(2.0), "timeout")
	var gareas = $FOV.get_overlapping_areas()
	var player_still_in = false
	for g in gareas:
		if g.is_in_group("PlayerArea"):
			player_still_in = true
			
	if not player_still_in:
		set_state(Types.CameraStates.Normal)
	else:
		player_in_fov = true
		print("back in fow")
		set_state(Types.CameraStates.Suspect)
		if not isFixedCam:
			$RotationTimer.start()

	
func set_state(new_state) -> void:
	if state != new_state:
		state = new_state
	
		match state:
			Types.CameraStates.Normal:
				if not $SureDetectionTimer.is_stopped():
					$SureDetectionTimer.stop()
				if "left" in $AnimationPlayer.assigned_animation:
					animation("idle_left")
				else:
					animation("idle_right")
					
			Types.CameraStates.Suspect:
				#print("Suspect mode")
				print( $AnimationPlayer.assigned_animation )
				
				if not $SureDetectionTimer.is_stopped():
					$SureDetectionTimer.stop()
				if "left" in $AnimationPlayer.assigned_animation:
					animation("susp_left")
					$AnimationPlayer.seek(0,true)
				else:
					animation("susp_right")
					$AnimationPlayer.seek(0,true)
					
			Types.CameraStates.PlayerDetected:
				if $SureDetectionTimer.is_stopped():
					$SureDetectionTimer.start()
				if "left" in $AnimationPlayer.assigned_animation:
					animation("detection_left")
					$AnimationPlayer.seek(0,true)
				else:
					animation("detection_right")
					$AnimationPlayer.seek(0,true)
					
				Events.emit_signal("player_detected", Types.DetectionLevels.Possible)
				Events.emit_signal("play_sound", "camera_beep")
				$AnimationPlayer.stop()
				#reset rotation timer
				if not isFixedCam:
					$RotationTimer.stop()


func animation(anim):
	if $AnimationPlayer.current_animation != anim:
		$AnimationPlayer.play(anim)


func _on_RotationTimer_timeout():
	atm_rotating = true
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
			$AnimationPlayer.play("idle_right")
			$FOV.scale.x = 1
		else:
			camDirection = CamDirectionType.Left
			$AnimationPlayer.play("idle_left")
			$FOV.scale.x = -1

		$FOV/CollisionPolygon2D.set_deferred("disabled", false)
		atm_rotating = false
		

func deactivate() -> void:
	set_process(false)
	$AnimationPlayer.stop()
	$RotationTimer.stop()
	$FOV.set_deferred("monitoring", false)
