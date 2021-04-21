extends Area2D


func _ready() -> void:
	connect("body_entered", self, "onBodyEntered")
	connect("body_exited", self, "onBodyExited")

	
func onBodyEntered(body: Node) -> void:
	if body.is_in_group("Player"):
		body.set_state(Types.PlayerStates.Duck)
		body.forcedDuckState = true


func onBodyExited(body: Node) -> void:
	if body.is_in_group("Player"):
		body.forcedDuckState = false
		body.set_state(Types.PlayerStates.Normal)
