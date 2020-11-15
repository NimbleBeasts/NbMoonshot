extends Node2D

var state: int = Types.CameraStates.Normal
var player_in_fov: bool = false

enum CamDirectionType {Left, Right}

export(CamDirectionType) var camDirection = CamDirectionType.Left
export(bool) var isFixedCam = false
export (float, -360, 360) var fov_right_rotation_degrees: float
export (float, -360, 360) var fov_left_rotation_degrees: float = -299.5

var currentDirection = camDirection


func _ready():
	if camDirection == CamDirectionType.Left:
		animation("idle_left")
		$FOV.rotation_degrees = fov_left_rotation_degrees
	else:
		animation("idle_right")
		$FOV.rotation_degrees = fov_right_rotation_degrees

	
	if not isFixedCam:
		$RotationTimer.start()


func _process(_delta: float) -> void:
	if player_in_fov:
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
	

func _on_SureDetectionTimer_timeout() -> void:
	Events.emit_signal("player_detected", Types.DetectionLevels.Sure)


func set_state(new_state) -> void:
	if state != new_state:
		state = new_state
	
		match state:
			Types.CameraStates.Normal:
				if not $SureDetectionTimer.is_stopped():
					$SureDetectionTimer.stop()
			Types.CameraStates.PlayerDetected:
				if $SureDetectionTimer.is_stopped():
					$SureDetectionTimer.start()
				Events.emit_signal("player_detected", Types.DetectionLevels.Possible)
	

func animation(anim):
	if $AnimationPlayer.current_animation != anim:
		$AnimationPlayer.play(anim)


func _on_RotationTimer_timeout():
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
			$FOV.rotation_degrees = fov_right_rotation_degrees
		else:
			camDirection = CamDirectionType.Left
			$AnimationPlayer.play("idle_left")
			$FOV.rotation = fov_left_rotation_degrees

		$FOV/CollisionPolygon2D.set_deferred("disabled", false)
		
