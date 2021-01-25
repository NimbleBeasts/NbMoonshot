extends Area2D

signal apply_gravity()
var colliders: Array = []
export var areaCollidersGroup: String

func _ready():
	connect("body_entered", self, "onBodyEntered")
	connect("body_exited", self, "onBodyExited")
	connect("area_entered", self, "onAreaEntered")
	connect("area_exited", self, "onAreaExited")


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


func onAreaEntered(area: Area2D) -> void:
	if area.is_in_group("AreaGround"):
		colliders.append(area)


func onAreaExited(area: Area2D) -> void:
	if area in colliders:
		colliders.erase(area)
		if colliders == []:
			emit_signal("apply_gravity")
