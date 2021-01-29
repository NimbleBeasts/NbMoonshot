extends Area2D

signal apply_gravity()
var colliders: Array = []
export var areaCollidersGroup: String

func _ready() -> void:
	connect("body_entered", self, "onBodyEntered")
	connect("body_exited", self, "onBodyExited")

func _process(delta):
	if get_overlapping_bodies() == []:
		emit_signal("apply_gravity")
	set_process(false)


func onBodyEntered(body: Node) -> void:
	colliders.append(body)


func onBodyExited(body: Node) -> void:
	colliders.erase(body)
	if colliders == []:
		emit_signal("apply_gravity")

