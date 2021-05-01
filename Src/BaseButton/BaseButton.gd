tool
extends TextureButton

export(String) var label = "Button"

func _ready():
	$Label.set_text(label)

func updateLabel(text):
	label = text
	_ready()


func _on_BaseButton_button_up():
	if not $MenuClick.playing:
		$MenuClick.play()
		emit_signal("button_up")
