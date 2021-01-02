extends Label

var unit

func setVisibility(visible: bool) -> void:
	modulate.a = int(visible)

	
func setColor(color: Color) -> void:
	set("custom_colors/font_color", color)
