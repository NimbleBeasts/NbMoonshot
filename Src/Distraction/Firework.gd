extends Area2D

var player: Player
export (Array, NodePath) var guards: Array



func _ready() -> void:
	set_process(false)
	connect("body_entered", self, "onBodyEntered")
	connect("body_exited", self, "onBodyExited")
	$Sprite.frame = 0
	#TODO: play sound


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and guards.size() >= 1 and player.canInteract:
		$AnimationPlayer.play("distraction")
		
		for guardPath in guards:
			var guard = get_node(guardPath)
			if not guard.inDistractMode:
				guard.distractMode()


func onBodyEntered(body: Node) -> void:
	if body.is_in_group("Player"):
		player = body
		set_process(true)

func onBodyExited(body: Node) -> void:
	if body.is_in_group("Player"):
		player = null
		set_process(false)
