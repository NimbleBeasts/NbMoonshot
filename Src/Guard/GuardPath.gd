extends Path2D
class_name GuardPath

signal loop_finished

export (Array, int) var stop_indexes = [1,3]
export var stop_time: float = 1.5
var global_points: Array = []
var tween: Tween = Tween.new()
var next_point: Vector2
var enabled: bool = true

onready var guard: Guard = get_parent()


func _ready() -> void:
	# signal connections
	guard.connect("stop_movement", self, "_on_guard_stop_movement")
	guard.connect("start_movement", self, "_on_guard_start_movement")
	guard.connect("unstunned", self, "_on_guard_unstunned")

	connect("loop_finished", self, "_on_loop_finished")
	add_child(tween)

	for i in curve.get_baked_points().size():
		global_points.append(guard.to_global(curve.get_baked_points()[i]))
	
	move_along_points(global_points)
	guard.block_movement = true

# this function took me 2 hours, fak. at least it kinda works
func move_along_points(a_points: Array) -> void:
	var points := a_points
	for i in points.size():
		# tweening
		if not stop_indexes.has(i):
			next_point = points[i]
			var duration = guard.global_position.distance_to(global_points[i]) / 20 # getting the duration that we need for the tween
			tween.interpolate_property(guard, "global_position:x", guard.global_position.x, global_points[i].x, duration, Tween.TRANS_LINEAR)
			tween.start()
			print("keep going")
			
			# checking which direction we're going
			if points[i].x > guard.global_position.x:
				guard.direction.x = 1
			elif points[i].x < guard.global_position.x:
				guard.direction.x = -1
			
			yield(tween, "tween_all_completed") # delays next iteration
		else:
			tween.stop_all()
			print("stop pls")
			guard.direction.x = 0
			yield(get_tree().create_timer(1.5), "timeout") # stops for this amount of time
			continue
	
	global_points.shuffle() # reorders the points
	emit_signal("loop_finished")


func _on_loop_finished() -> void:
	if enabled:
		move_along_points(global_points)


func _on_guard_stop_movement() -> void:
	enabled = false
	tween.stop_all()


func _on_guard_start_movement() -> void:
	enabled = true

	
func _on_guard_unstunned() -> void:
	move_along_points(global_points)