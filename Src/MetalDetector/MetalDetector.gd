extends Node2D

var active = true

func _ready():
	pass # Replace with function body.

func deactivate() -> void:
	active = false

func alarm():
	$AnimationPlayer.play("alarm")
	Events.emit_signal("player_detected", Types.DetectionLevels.Sure)


func _on_DelayTimer_timeout():
	alarm()

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player") and active:
		$DelayTimer.start()
		active = false


