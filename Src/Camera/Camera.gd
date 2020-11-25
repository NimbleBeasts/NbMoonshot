extends Node2D

var state: int = Types.CameraStates.Normal
var player_in_fov: bool = false

enum CamDirectionType {Left, Right}

export(CamDirectionType) var camDirection = CamDirectionType.Left
export(bool) var isFixedCam = false


var currentDirection = camDirection


func _ready():
	if camDirection == CamDirectionType.Left:
		$AnimationPlayer.current_animation = "idle_left"
		$FOV.scale.x = -1
		currentDirection = CamDirectionType.Right;
	else:
		$AnimationPlayer.current_animation = "idle_right"
		$FOV.scale.x = 1

	
	if not isFixedCam:
		$RotationTimer.start()


func _process(_delta: float) -> void:
	if state == Types.CameraStates.Rotating or state == Types.CameraStates.Frozen:
		pass
	else:
		figure_out_state()


func _on_FOV_area_entered(area: Area2D) -> void:
	if state != Types.CameraStates.Rotating:
		if area.is_in_group("PlayerArea"):
			player_in_fov = true
			#print("Player enter")
	

func _on_FOV_area_exited(area: Area2D) -> void:
	if state != Types.CameraStates.Rotating:
		if area.is_in_group("PlayerArea"):
			player_in_fov = false
			#print("Player exit")

func _on_SureDetectionTimer_timeout() -> void:
	Events.emit_signal("player_detected", Types.DetectionLevels.Sure)
	Events.emit_signal("play_sound", "camera_alarm")
	
func _on_FrozenTimer_timeout():
	figure_out_state()

	
func figure_out_state():
	if player_in_fov:	
		match Global.player.visible_level:
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
		#print("S: ", state, " NS: ", new_state)
	
		
		match state:
			Types.CameraStates.Rotating:
				#print("went rot state")
			Types.CameraStates.Frozen:
				#print("went frozen state")
				$FrozenTimer.start()
				if not isFixedCam:
					$RotationTimer.stop()
			
			Types.CameraStates.Normal:
				if not $SureDetectionTimer.is_stopped():
					$SureDetectionTimer.stop()
				if not isFixedCam and $RotationTimer.is_stopped():
					$RotationTimer.start()
					
				if currentDirection == CamDirectionType.Right:
					animation("idle_left")
				else:
					animation("idle_right")
					
			Types.CameraStates.Suspect:	
				if not $SureDetectionTimer.is_stopped():
					$SureDetectionTimer.stop()
				if not isFixedCam and $RotationTimer.is_stopped():
					$RotationTimer.start()
					
				if currentDirection == CamDirectionType.Right:
					animation("susp_left")
					$AnimationPlayer.seek(0,true)
				else:
					animation("susp_right")
					$AnimationPlayer.seek(0,true)
					
			Types.CameraStates.PlayerDetected:
				
				if $SureDetectionTimer.is_stopped():
					$SureDetectionTimer.start()
					
				if currentDirection == CamDirectionType.Right:
					animation("detection_left")
					$AnimationPlayer.seek(0,true)
				else:
					animation("detection_right")
					$AnimationPlayer.seek(0,true)
					
				Events.emit_signal("player_detected", Types.DetectionLevels.Possible)
				Events.emit_signal("play_sound", "camera_beep")
				
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
		else:
			camDirection = CamDirectionType.Left
			$FOV.scale.x = -1

		$FOV/CollisionPolygon2D.set_deferred("disabled", false)
		#print("exited rot state")
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
	$FOV.set_deferred("monitoring", false)



