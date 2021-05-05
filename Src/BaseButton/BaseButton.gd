tool
extends BaseButton


func _on_BaseButton_button_up():
	if not $MenuClick.playing:
		$MenuClick.play()



func _on_BaseButtonSmall_button_up():
	_on_BaseButton_button_up()
