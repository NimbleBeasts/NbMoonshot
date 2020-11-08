class_name NPC
extends KinematicBody2D

signal player_interacted


func _ready() -> void:
	connect("player_interacted", self, "_on_player_interacted")

