tool
extends BaseButton


func _on_BaseButton_button_up():
	if not $MenuClick.playing:
		$MenuClick.play()
		emit_signal("button_up")
