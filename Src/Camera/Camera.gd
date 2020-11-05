extends Node2D

var state: int = Types.CameraStates.Normal
	

func _on_FOV_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		# checks player visible level and sets state according to that
		match Global.player.visible_level:
			Types.LightLevels.FullLight:
				set_state(Types.CameraStates.PlayerDetected)
				Events.emit_signal("player_detected", Types.DetectionLevels.Possible)
			Types.LightLevels.BarelyVisible:
				set_state(Types.CameraStates.Suspect)
			Types.LightLevels.Dark:
				set_state(Types.CameraStates.Normal)

	
func _on_FOV_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		set_state(Types.CameraStates.Normal)
	
	
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
		
