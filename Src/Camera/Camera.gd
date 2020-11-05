extends Node2D

var player_detected: bool = false

func _on_FOV_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		Events.emit_signal("player_detected", Types.DetectionLevels.Possible)
		player_detected = true
		if $SureDetectionTimer.is_stopped():
			$SureDetectionTimer.start()
		
		
func _on_FOV_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		player_detected = false
		if not $SureDetectionTimer.is_stopped():
			$SureDetectionTimer.stop()
	
	
func _on_SureDetectionTimer_timeout() -> void:
	Events.emit_signal("player_detected", Types.DetectionLevels.Sure)
