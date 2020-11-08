class_name NPC
extends Area2D

signal player_interacted


func _ready() -> void:
	connect("player_interacted", self, "_on_player_interacted")
	connect("body_entered", self, "_on_body_entered")


func _on_body_entered(body: Node) -> void:
	if body is Player:
		emit_signal("player_interacted")
		Events.emit_signal("interacted_with_npc", self)
