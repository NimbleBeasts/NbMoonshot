extends Node2D


export(bool) var canHidePlayer = true
export(bool) var canBeOpened = true

func _ready():
	if not canBeOpened:
		self.remove_child($Area2D)

func getPoint():
	return $Position2D.global_position


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		pass


func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		pass

