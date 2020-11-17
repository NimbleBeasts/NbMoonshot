tool
extends TextureButton

export(String) var label = "Button"

func _ready():
	$Label.set_text(label)

func updateLabel(text):
	label = text
	_ready()
