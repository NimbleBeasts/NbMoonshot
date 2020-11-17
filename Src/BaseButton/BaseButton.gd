tool
extends TextureButton

export(String) var label = "Button"

func _ready():
	$Label.set_text(label)


