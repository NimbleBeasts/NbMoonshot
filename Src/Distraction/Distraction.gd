extends Area2D

var player: Player
export (Array, NodePath) var guards: Array

func _ready() -> void:
	set_process(false)
	connect("body_entered", self, "onBodyEntered")
	connect("body_exited", self, "onBodyExited")


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		for guardPath in guards:
			var guard = get_node(guardPath)
			guard.distractMode()
			Events.emit_signal("play_sound", "suspicious")


func onBodyEntered(body: Node) -> void:
	if body.is_in_group("Player"):
		player = body
		set_process(true)

func onBodyExited(body: Node) -> void:
	if body.is_in_group("Player"):
		player = null
		set_process(false)
