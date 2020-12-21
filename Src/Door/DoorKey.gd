extends Area2D

export (Types.KeyColors) var keyColor: int

var isPickedUp: bool = false
var stringName: String


func _ready() -> void:
	connect("body_entered", self, "onBodyEntered")
	stringName = Types.KeyColors.keys()[keyColor].to_lower()


func onBodyEntered(body: Node) -> void:
	if body.is_in_group("Player"):
		isPickedUp = true
		hide()
		Events.emit_signal("hud_game_hint", "Found a %s key" % stringName)
