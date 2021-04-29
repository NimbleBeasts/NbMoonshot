extends Area2D

var player: Player
export (Array, NodePath) var guards: Array

func _ready() -> void:
	set_process_unhandled_input(false)
	connect("body_entered", self, "onBodyEntered")
	connect("body_exited", self, "onBodyExited")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and guards.size() >= 1 and player.canInteract:
		for guardPath in guards:
			var guard = get_node(guardPath)
			if not guard.inDistractMode:
				guard.distractMode()

func onBodyEntered(body: Node) -> void:
	if body.is_in_group("Player"):
		player = body
		set_process_unhandled_input(true)


func onBodyExited(body: Node) -> void:
	if body.is_in_group("Player"):
		player = null
		set_process_unhandled_input(false)
