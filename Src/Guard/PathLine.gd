extends Line2D
class_name PathLine

# reworked this to remove all yields and be less magic - knightmare

signal next_point_reached

export var stop_time: float = 1.5
export var stopOnReachedPoint: bool = true
export var distractWaitTime: float = 2

const SAFETY_MARGIN: int = 4

var global_points: Array = []
var next_point: Vector2
var last_point: Vector2
var enabled: bool = true
var is_next_point_reached: bool
var movingToCustomPoint: bool = false
var currentIndex: int

# Timer
var waitTimer: Timer = Timer.new()
var distractTimer: Timer = Timer.new() # Waiting time on distraction target

var isDistract: bool = false

onready var target = get_parent()

var debug_start_position = Vector2(0, 0)
var parent_position = Vector2(0, 0)

func _ready() -> void:
	# Setup Timers
	add_child(distractTimer)
	distractTimer.connect("timeout", self, "_onDistractTimerTimeout")
	distractTimer.one_shot = true
	distractTimer.wait_time = distractWaitTime

	add_child(waitTimer)
	waitTimer.connect("timeout", self, "_onWaitTimerTimeout")
	waitTimer.one_shot = true
	waitTimer.wait_time = stop_time
	
	hide()

	# Add points to array
	for i in points.size():
		global_points.append(target.to_global(points[i]))
	
	debug_start_position = get_parent().global_position
	#print(debug_start_position)
	last_point = global_points[0]
	
	moveToNextPoint()

	if global_points.size() >= 1:
		next_point = global_points[0]

func _draw():

	draw_circle(debug_start_position - parent_position, 4, Color("#00ff00"))
	
	for i in points:
		draw_circle(i + debug_start_position - parent_position, 4, Color("#ff0000"))

func _physics_process(delta) -> void:
	parent_position = get_parent().global_position
	#print(parent_position)
	
	if enabled or movingToCustomPoint:
		# Point reached
		if abs(int(next_point.x) - int(target.global_position.x)) <= SAFETY_MARGIN:
			target.direction.x = 0
			if not is_next_point_reached:
				is_next_point_reached = true
				emit_signal("next_point_reached")
				
				if not movingToCustomPoint:
					moveToNextPoint()
		elif int(next_point.x) > int(target.global_position.x):
			# Move Right
			target.direction.x = 1
			is_next_point_reached = false
		elif int(next_point.x) < int(target.global_position.x):
			# Move Left
			target.direction.x = -1
			is_next_point_reached = false
	update()

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
		waitTimer.start()
	else:
		last_point = next_point
		next_point = global_points[currentIndex]


func moveToPoint(newPoint: Vector2) -> void:
	last_point = next_point
	next_point = newPoint
	moveToNextPoint()
	enabled = false
	movingToCustomPoint = true
	waitTimer.stop()


func startNormalMovement() -> void:
	movingToCustomPoint = false
	enabled = true

	
func stopAllMovement() -> void:
	enabled = false
	movingToCustomPoint = false
	target.direction = Vector2(0,0)
	waitTimer.stop()

	
func changeDirection() -> void:
	enabled = true
	movingToCustomPoint = false
	global_points.invert()
	waitTimer.start()


func moveToLastPoint() -> void:
	next_point = last_point
	global_points.invert()
	moveToNextPoint()
	enabled = true
	movingToCustomPoint = false
	waitTimer.start()



func _onWaitTimerTimeout() -> void:
	if global_points.size() - 1 >= currentIndex:
		last_point = next_point
		next_point = global_points[currentIndex]

# Wait time at distraction is over - return to normal mode
func _onDistractTimerTimeout() -> void:
	if target.has_method("normalMode"):
		target.normalMode()
