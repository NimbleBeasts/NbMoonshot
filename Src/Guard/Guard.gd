class_name Guard
extends KinematicBody2D

export var speed: int = 50
export var direction_change_time: float = 2
export var starting_direction: Vector2
export var time_to_sure_direction: float = 1.5

var velocity: Vector2
var direction: Vector2
var moving_right: bool = true
var player_detected: bool = false


func _ready() -> void:
	$DirectionChangeTimer.wait_time = direction_change_time
	$DirectionChangeTimer.start()
	direction = starting_direction 
	$SureDetectionTimer.wait_time = time_to_sure_direction


func _process(delta: float) -> void:
	velocity = direction * speed
	velocity = move_and_slide(velocity)
	

func _on_DirectionChangeTimer_timeout():
	change_direction()
	

func change_direction() -> void:
	# flips moving_right, also flips the direction.x
	moving_right = not moving_right
	direction.x *= -1


func _on_LineOfSight_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		Events.emit_signal("player_detected", Types.DetectionLevels.Possible)
		player_detected = true
		direction = Vector2(0,0)
		if $SureDetectionTimer.is_stopped():
			$SureDetectionTimer.start()


func _on_SureDetectionTimer_timeout() -> void:
	Events.emit_signal("player_detected", Types.DetectionLevels.Sure)
