extends Path2D

signal loop_finished

export (Array, int) var stop_indexes = []
var global_points: Array = []
var tween: Tween = Tween.new()

onready var guard: Guard = get_parent()


func _ready() -> void:
	connect("loop_finished", self, "_on_loop_finished")
	add_child(tween)

	for i in curve.get_baked_points().size():
		global_points.append(guard.to_global(curve.get_baked_points()[i]))
	
	move_along_points(global_points)


func move_along_points(a_points: Array) -> void:
	var points := a_points
	for i in points.size():
		if not stop_indexes.has(i):
			var duration = guard.global_position.distance_to(global_points[i]) / 20
			tween.interpolate_property(guard, "global_position:x", guard.global_position.x, global_points[i].x, duration, Tween.TRANS_LINEAR)
			tween.start()
			print("keep going")
			yield(tween, "tween_all_completed")
		else:
			tween.stop_all()
			print("stop pls")
			yield(get_tree().create_timer(1.5), "timeout")
			continue
	
	global_points.shuffle()
	emit_signal("loop_finished")


func _on_loop_finished() -> void:
	print("finished")
	move_along_points(global_points)
