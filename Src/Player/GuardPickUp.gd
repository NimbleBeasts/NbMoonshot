extends Area2D

export var rightOffset: Vector2
export var leftOffset: Vector2
var guard: Guard
var isDraggingGuard: bool
onready var player: Player = get_parent()


func _ready() -> void:
	set_process(false)
	connect("body_entered", self, "onBodyEntered")
	connect("body_exited", self, "onBodyExited")


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and guard.state == Types.GuardStates.Stunned and guard.isSleeping:
		guard.set_state(Types.GuardStates.BeingDragged)
		player.set_state(Types.PlayerStates.DraggingGuard)
		isDraggingGuard = true
		return

	if guard.state == Types.GuardStates.BeingDragged:
		if player.direction.x > 0:
			guard.global_position = player.global_position + rightOffset
		elif player.direction.x < 0:
			guard.global_position = player.global_position + leftOffset
		if Input.is_action_just_pressed("interact"):
			stopDragging()


func onBodyEntered(body: Node) -> void:
	if body.is_in_group("Guard") and guard == null:
		guard = body
		set_process(true)


func onBodyExited(body: Node) -> void:
	if body == guard:
		guard = null
		set_process(false)


func stopDragging() -> void:
	if guard:
		guard.state = Types.GuardStates.Stunned
		player.set_state(Types.PlayerStates.Normal)
		isDraggingGuard = false
