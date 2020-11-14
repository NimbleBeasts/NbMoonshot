extends Path2D
class_name GuardPath

signal loop_finished
signal next_point_reached

export (Array, int) var stop_indexes = [1,3]
export var stop_time: float = 1.5
var global_points: Array = []
var next_point: Vector2
var enabled: bool = true
var is_next_point_reached: bool

onready var guard: Guard = get_parent()


func _ready() -> void:
	# signal connections
	guard.connect("stop_movement", self, "_on_guard_stop_movement")
	guard.connect("start_movement", self, "_on_guard_start_movement")
	curve.bake_interval = 20

	connect("loop_finished", self, "_on_loop_finished")

	for i in curve.get_baked_points().size():
		global_points.append(guard.to_global(curve.get_baked_points()[i]))
	
	move_along_points()


func _process(delta: float) -> void:
	if enabled:
		if int(next_point.x) > int(guard.global_position.x):
			guard.direction.x = 1
			is_next_point_reached = false
		elif int(next_point.x) < int(guard.global_position.x):
			guard.direction.x = -1
			is_next_point_reached = false
		else:
			guard.direction.x = 0
			if not is_next_point_reached:
				is_next_point_reached = true
				emit_signal("next_point_reached")


# moves along a array of vector2s
func move_along_points() -> void:
	if enabled:
		for i in global_points.size():
			if i == global_points.size() - 1:
				global_points.shuffle() # maybe we can reverse the array instead of shuffling it
				emit_signal("loop_finished")
			if enabled:
				if not stop_indexes.has(i):
					next_point = global_points[i]
					yield(self, "next_point_reached") # delays next iteration
				else:
					guard.direction.x = 0
					yield(get_tree().create_timer(stop_time), "timeout") # stops for this amount of time
					continue
				
		global_points.shuffle() # reorders the points
		emit_signal("loop_finished")


func _on_loop_finished() -> void:
	move_along_points()


func _on_guard_stop_movement() -> void:
	enabled = false
	print("STAHP")
	guard.direction.x = 0


func _on_guard_start_movement() -> void:
	enabled = true
	move_along_points()
