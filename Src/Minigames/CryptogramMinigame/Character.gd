extends Label

var unit
var keyLabel
var correctText: String


func setVisibility(visible: bool) -> void:
	modulate.a = int(visible)


func setColor(color: Color) -> void:
	set("custom_colors/font_color", color)


func onSelectedCharacterChanged(newCharacter) -> void:
	if newCharacter == self:
		$Sprite.show()
		return
	$Sprite.hide()
