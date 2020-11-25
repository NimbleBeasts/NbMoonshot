extends Sprite

signal button_clicked(num)

export(String) var label = "9"

var timer: Timer = Timer.new() # timer that releases the button for keyboard presses

func _ready():
	add_child(timer)
	timer.one_shot = true
	timer.connect("timeout", self, "onTimerTimeout")
	$Label.set_text(label)

func _on_TextureButton_button_down():
	press()


func _on_TextureButton_button_up():
	release()


func press() -> void:
	timer.start(0.1)
	self.frame = 1
	$Label.rect_position.y = 2
	emit_signal("button_clicked", $Label.text)
	if not label == "*":
		Events.emit_signal("play_sound", "keypad_input")
	else:
		Events.emit_signal("play_sound", "keypad_clear")


func release() -> void:
	self.frame = 0
	$Label.rect_position.y = 0


func onTimerTimeout() -> void:
	release()