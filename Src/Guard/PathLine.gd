extends Line2D
class_name PathLine

# reworked this to remove all yields and be less magic - knightmare

signal next_point_reached


export var stop_time: float = 1.5
export var stopOnReachedPoint: bool = true

var global_points: Array = []
var next_point: Vector2
var enabled: bool = true
var is_next_point_reached: bool
var movingToCustomPoint: bool = false
var currentIndex: int
var timer: Timer = Timer.new()

onready var target = get_parent()


func _ready() -> void:
	add_child(timer)
	timer.connect("timeout", self, "onTimerTimeout")
	timer.one_shot = true
	timer.wait_time = stop_time
	hide()

	for i in points.size():
		global_points.append(target.to_global(points[i]))
	
	moveToNextPoint()	


func _process(delta: float) -> void:
	if enabled or movingToCustomPoint:
		if int(next_point.x) > int(target.global_position.x):
			target.direction.x = 1
			is_next_point_reached = false
		elif int(next_point.x) < int(target.global_position.x):
			target.direction.x = -1
			is_next_point_reached = false
		else:
			target.direction.x = 0
			if not is_next_point_reached:
				is_next_point_reached = true
				emit_signal("next_point_reached")
				if not movingToCustomPoint:
					moveToNextPoint()


func onTimerTimeout() -> void:
	next_point = global_points[currentIndex]


func moveToNextPoint():
	if currentIndex >= global_points.size() - 1:
		currentIndex = 0
		global_points.invert()
	currentIndex += 1
	if stopOnReachedPoint:
		timer.start()
	else:
		next_point = global_points[currentIndex]
		

func moveToPoint(newPoint: Vector2) -> void:
	next_point = newPoint
	moveToNextPoint()
	enabled = false
	movingToCustomPoint = true
	timer.stop()


func startNormalMovement() -> void:
	movingToCustomPoint = false
	enabled = true
	timer.start()


func stopAllMovement() -> void:
	enabled = false
	movingToCustomPoint = false
	target.direction = Vector2(0,0)
	timer.stop()

	
func changeDirection() -> void:
	enabled = true
	movingToCustomPoint = false
	global_points.invert()
	timer.start()
