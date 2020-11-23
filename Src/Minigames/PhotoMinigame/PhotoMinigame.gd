extends Minigame

var lineDirection: Vector2
var lineVelocity: Vector2 
var lineSpeed: float = 250
var lineInTarget: bool = false

onready var line: Area2D = $Line

func _ready() -> void:
	$ChangeDirection.add_to_group("ChangeDirection")
	$ChangeDirection2.add_to_group("ChangeDirection")
	line.connect("area_entered", self, "onLineAreaEntered")
	line.connect("area_exited", self, "onLineAreaExited")
	lineDirection.x = 1


func _physics_process(delta: float) -> void:
	lineVelocity = lineDirection * lineSpeed
	line.position += lineVelocity * delta

	if lineInTarget:
		if Input.is_action_just_pressed("ui_up"):
			lineDirection.x = 0
			set_result(Types.MinigameResults.Succeeded)
			close()
			

func onLineAreaEntered(area: Area2D) -> void:
	if area.is_in_group("ChangeDirection"): 
		changeLineDirection()
	elif area.is_in_group("LineTarget"):
		lineInTarget = true


func onLineAreaExited(area: Area2D) -> void:
	if area.is_in_group("LineTarget"):
		lineInTarget = false


func changeLineDirection() -> void:
	lineDirection.x *= -1
