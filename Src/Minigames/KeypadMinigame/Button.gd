extends Sprite

signal button_clicked(num)

export(String) var label = "9"

func _ready():
	$Label.set_text(label)

func _on_TextureButton_button_down():
	self.frame = 1
	$Label.rect_position.y = 2
	emit_signal("button_clicked", $Label.text)


func _on_TextureButton_button_up():
	self.frame = 0
	$Label.rect_position.y = 0
