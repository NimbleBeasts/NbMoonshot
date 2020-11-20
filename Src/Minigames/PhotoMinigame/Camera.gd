extends Area2D

export var moveSpeed: float = 1000
var direction: Vector2


func _process(delta: float) -> void:
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	position += (direction * moveSpeed) * delta

