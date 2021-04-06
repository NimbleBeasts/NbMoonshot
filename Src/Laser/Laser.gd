extends Area2D

var player_entered: bool = false
var playerState: int

func _ready() -> void:
	Events.connect("player_state_changed", self, "onPlayerStateChanged")

func _process(_delta: float) -> void:
	if player_entered:
		if playerState != Types.PlayerStates.WallDodge:
			Events.emit_signal("player_detected", Types.DetectionLevels.Possible)
			set_process(false)

			
func _on_Laser_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		player_entered = true
		set_process(true)


func _on_Laser_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		player_entered = false
		set_process(false)


func _on_Timer_timeout() -> void:
	$CollisionShape2D.disabled = not $CollisionShape2D.disabled


func onPlayerStateChanged(newState: int) -> void:
	playerState = newState
