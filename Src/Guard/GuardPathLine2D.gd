extends Line2D
class_name GuardPathLine

# this is kinda meh but it works :DDDDDDDDD

signal loop_finished
signal next_point_reached

export var stop_time: float = 1.5
var global_points: Array = []
var next_point: Vector2
var enabled: bool = true
var is_next_point_reached: bool
var movingToCustomPoint: bool = false

onready var guard: Guard = get_parent()


func _ready() -> void:
	hide()
	# signal connections
	guard.connect("stop_movement", self, "_on_guard_stop_movement")
	guard.connect("start_movement", self, "_on_guard_start_movement")

	connect("loop_finished", self, "_on_loop_finished")

	for i in points.size():
		global_points.append(guard.to_global(points[i]))
	
	move_along_points()


func _process(delta: float) -> void:
	# this probably should be refactored but i don't feel like it :D
	if enabled or movingToCustomPoint:
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
				global_points.invert()
				emit_signal("loop_finished")
			if enabled:
				next_point = global_points[i]
				yield(self, "next_point_reached") # delays next iteration, i know i shouldn't use yield but fuk it, it works :DDDDDD
				guard.direction.x = 0
				yield(get_tree().create_timer(stop_time), "timeout") # stops for this amount of time
				continue


func moveToPoint(newPoint: Vector2) -> void:
	next_point = newPoint
	enabled = false
	movingToCustomPoint = true


func startNormalMovement() -> void:
	movingToCustomPoint = false
	enabled = true


func stopAllMovement() -> void:
	enabled = false
	movingToCustomPoint = false
	guard.direction = Vector2(0,0)

	
func _on_loop_finished() -> void:
	move_along_points()


func _on_guard_stop_movement() -> void:
	enabled = false
	guard.direction.x = 0


func _on_guard_start_movement() -> void:
	enabled = true
	move_along_points()
