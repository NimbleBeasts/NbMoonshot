extends Area2D

export var moveSpeed: float = 1000
var direction: Vector2
var canMove: bool = true

func _process(delta: float) -> void:
	if canMove:
		direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

		position += (direction * moveSpeed) * delta

