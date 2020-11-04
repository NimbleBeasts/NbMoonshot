extends Node2D

export(float) var pulseDelay = 2.5
export(float) var pollingTimer = 1

var isPaying = false


func _ready():
	$PulseDelayTimer.wait_time = pulseDelay
	$PulseDelayTimer.start()
	
	if JavaScript.eval("(document.monetization !== null);"):
		$PollingTimer.start()
		_on_PollingTimer_timeout()
		$AnimationPlayer.play("active_idle")
	else:
		$AnimationPlayer.play("inactive_idle")


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"active_pulse":
			$AnimationPlayer.play("active_idle")
			Events.emit_signal("web_monetization_pulse", isPaying)
		"inactive_pulse":
			$AnimationPlayer.play("inactive_idle")
		_:
			pass


func _on_PulseDelayTimer_timeout():
	if isPaying:
		$AnimationPlayer.play("active_pulse")
	else:
		$AnimationPlayer.play("inactive_pulse")


func _on_PollingTimer_timeout():
	if JavaScript.eval("(document.monetization.state === 'started');"):
		isPaying = true
	else:
		isPaying = false
