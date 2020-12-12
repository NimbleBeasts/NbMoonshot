extends Camera2D

var timer := Timer.new()


func _ready() -> void:
	add_child(timer)
	timer.one_shot = true
	timer.connect("timeout", self, "onTimerTimeout")
	Events.connect("minigame_exited", self, "_on_minigame_exited")


func shake_camera() -> void:
	$AnimationPlayer.play("shake")


func _on_minigame_exited(result: int) -> void:
	if result == Types.MinigameResults.Failed:
		shake_camera()		


func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	if event.is_action_pressed("selection"):
		timer.start(0.6)
	elif event.is_action_released("selection"):
		timer.stop()


func onTimerTimeout() -> void:
	Events.emit_signal("held_selection")