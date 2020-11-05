class_name Guard
extends KinematicBody2D

export var speed: int = 50
export var direction_change_time: float = 2
export var starting_direction: Vector2
export var time_to_sure_direction: float = 1.5
export var stun_duration: float = 2

var velocity: Vector2
var direction: Vector2
var player_detected: bool = false
var is_stunned: bool = false
var state: int = Types.GuardStates.Wander # Types.GuardStates


func _ready() -> void:
	# sets the wait_time to the exported variable
	$DirectionChangeTimer.wait_time = direction_change_time
	$SureDetectionTimer.wait_time = time_to_sure_direction
	$StunDurationTimer.wait_time = stun_duration
	$DirectionChangeTimer.start()
	direction = starting_direction


func _process(delta: float) -> void:
	velocity = direction * speed
	velocity = move_and_slide(velocity)


func change_direction() -> void:
	# flips moving_right, also flips the direction.x
	direction.x *= -1


# stun function.
func stun() -> void:
	direction = Vector2(0,0)
	$Sprite.modulate = Color.black
	is_stunned = true
	if $StunDurationTimer.is_stopped():
		$StunDurationTimer.start()


func unstun() -> void:
	direction = starting_direction
	$Sprite.modulate = Color.white
	is_stunned = false
	
	
func _on_DirectionChangeTimer_timeout():
	change_direction()
	
	
func _on_LineOfSight_area_entered(area: Area2D) -> void:
	# detecting player
	if area.is_in_group("PlayerArea") and not is_stunned:
		
		# checks player visible level and sets state according to that
		match Global.player.visible_level:
			Types.LightLevels.FullLight:
				set_state(Types.GuardStates.PlayerDetected)
				Events.emit_signal("player_detected", Types.DetectionLevels.Possible)
			Types.LightLevels.BarelyVisible:
				set_state(Types.GuardStates.Suspect)
			Types.LightLevels.Dark:
				set_state(Types.GuardStates.Wander)
				
		direction = Vector2(0,0)
		if $SureDetectionTimer.is_stopped():
			$SureDetectionTimer.start()


func _on_SureDetectionTimer_timeout() -> void:
	Events.emit_signal("player_detected", Types.DetectionLevels.Sure)


func _on_StunDurationTimer_timeout() -> void:
	unstun()


func set_state(new_state) -> void:
	if state != new_state:
		state = new_state
