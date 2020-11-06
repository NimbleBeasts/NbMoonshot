class_name Guard
extends KinematicBody2D

export var speed: int = 50
export var direction_change_time: float = 2
export var starting_direction: Vector2
export var time_to_sure_direction: float = 1.5
export var stun_duration: float = 2

var velocity: Vector2
var direction: Vector2
var is_stunned: bool = false
var state: int = Types.GuardStates.Wander # Types.GuardStates
var player_in_los: bool = false

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
	match state:
		Types.GuardStates.PlayerDetected:
			direction = Vector2(0,0)
			$DirectionChangeTimer.stop()
	
	# the player could be in dark visible level when the overlap happens and it would check according to that
	# then the player could move to full light and it wouldn't get called unless it's a new overlap
	# so we have to do set a bool on area entered and check in _process
	if player_in_los:
		match Global.player.visible_level:
			Types.LightLevels.FullLight:
				set_state(Types.GuardStates.PlayerDetected)
				player_in_los = false
			Types.LightLevels.BarelyVisible:
				set_state(Types.GuardStates.Suspect)
			Types.LightLevels.Dark:
				set_state(Types.GuardStates.Wander)
		
		
func change_direction() -> void:
	# flips the direction.x
	direction.x *= -1
	self.scale.x = direction.x * -1


# stun function.
func stun() -> void:
	direction = Vector2(0,0)
	$Sprite.modulate = Color.black
	is_stunned = true
	if $StunDurationTimer.is_stopped():
		$StunDurationTimer.start()
	# stops sure detection timer on stun
	if not $SureDetectionTimer.is_stopped():
		$SureDetectionTimer.stop()


func unstun() -> void:
	direction = starting_direction
	$Sprite.modulate = Color.white
	is_stunned = false
	
	
func _on_DirectionChangeTimer_timeout():
	if state == Types.GuardStates.Wander:
		change_direction()
	
	
func _on_LineOfSight_area_entered(area: Area2D) -> void:
	# detecting player
	if area.is_in_group("PlayerArea") and not is_stunned:
		player_in_los = true


# this gets started when this guard's state changes to PlayerDetected
# on timeout, meaning if not stunned within this time, the detection level of player gets to Sure
func _on_SureDetectionTimer_timeout() -> void:
	Events.emit_signal("player_detected", Types.DetectionLevels.Sure)


func _on_StunDurationTimer_timeout() -> void:
	unstun()


func set_state(new_state) -> void:
	if state != new_state:
		state = new_state
		
		match state:
			Types.GuardStates.PlayerDetected:
				if $SureDetectionTimer.is_stopped():
					$SureDetectionTimer.start()
				Events.emit_signal("player_detected", Types.DetectionLevels.Possible)


func _on_LineOfSight_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		player_in_los = false

