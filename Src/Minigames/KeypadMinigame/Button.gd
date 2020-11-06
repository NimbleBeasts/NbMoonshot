extends Button

signal button_clicked(num)

func _ready() -> void:
	connect("button_up", self, "_on_button_up")


func _on_button_up() -> void:
	emit_signal("button_clicked", int(text))
