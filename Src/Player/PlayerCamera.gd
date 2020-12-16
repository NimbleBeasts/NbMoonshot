extends Camera2D

var timer := Timer.new()
var selectionHeld: bool = false
var camSpeed: int = 50
var camDirection: Vector2
var camVelocity: Vector2


func _ready() -> void:
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = 0.6
	timer.connect("timeout", self, "onTimerTimeout")
	Events.connect("minigame_exited", self, "_on_minigame_exited")


func shake_camera() -> void:
	$AnimationPlayer.play("shake")


func _on_minigame_exited(result: int) -> void:
	if result == Types.MinigameResults.Failed:
		shake_camera()		


func _process(delta: float) -> void:
	camDirection.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	camDirection.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	camVelocity = camDirection * camSpeed
	position += camVelocity * delta


func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	if event.is_action_pressed("selection") and timer.is_stopped():
		if not selectionHeld:
			Global.startTimerOnce(timer)
		else:
			timer.stop()
			Events.emit_signal("released_held_selection")
			releaseHeldSelection()

	if event.is_action_released("selection") and timer.time_left != 0:
		timer.stop()
		releaseHeldSelection()
		
		
func releaseHeldSelection() -> void:
	selectionHeld = false
	Events.emit_signal("unblock_player_movement")
	set_process(false)


func holdSelection() -> void:
	Events.emit_signal("block_player_movement")
	selectionHeld = true
	set_process(true)


func onTimerTimeout() -> void:
	Events.emit_signal("held_selection")
	holdSelection()
	