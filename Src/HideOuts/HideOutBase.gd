class_name HideOutBase
extends Node2D

export(bool) var canHidePlayer = true
export(bool) var canBeOpened = true

var player: Player
var playerInArea: bool


func _ready():
	$Area2D.connect("body_entered", self, "_on_Area2D_body_entered")
	$Area2D.connect("body_exited", self, "_on_Area2D_body_exited")
	if not canBeOpened:
		$Area2D.queue_free()


func getPoint():
	return $Position2D.global_position


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		playerInArea = true


func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		playerInArea = false