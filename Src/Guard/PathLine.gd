extends Line2D
class_name PathLine

# reworked this to remove all yields and be less magic - knightmare

signal next_point_reached

export var stop_time: float = 1.5
export var stopOnReachedPoint: bool = true
export var distractWaitTime: float = 2

var global_points: Array = []
var next_point: Vector2
var enabled: bool = true
var is_next_point_reached: bool
var movingToCustomPoint: bool = false
var currentIndex: int
var timer: Timer = Timer.new()
var distractTimer: Timer = Timer.new()

var isDistract: bool = false

onready var target = get_parent()


func _ready() -> void:
	add_child(timer)
	add_child(distractTimer)
	timer.connect("timeout", self, "onTimerTimeout")
	distractTimer.connect("timeout", self, "onDistractTimerTimeout")
	timer.one_shot = true
	distractTimer.one_shot = true

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
		if not isDistract:
			global_points.invert()
		else:
			# stopping because we reached the last point and this is for distraction
			stopAllMovement()
			distractTimer.start(distractWaitTime)
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
	timer.start(0.3) # experimental line of code, don't know if this will break anything else

	
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


func moveToStartingPoint() -> void:
	next_point = global_points[0]
	moveToNextPoint()
	enabled = true
	movingToCustomPoint = false
	timer.start()


func onDistractTimerTimeout() -> void:
	if target.has_method("normalMode"):
		target.normalMode()
