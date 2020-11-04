class_name Player
extends KinematicBody2D

# movement variables
export var normal_speed: int = 100
export var normal_acceleration: int = 600
export var sprint_speed: int = 400
export var sprint_acceleration: int = 2500

var direction: Vector2
var velocity: Vector2
var speed: int = normal_speed
var acceleration: int = normal_acceleration

var visible_level: int = Types.VisibleLevels.Dark #Use Types.VisibleLevels enum for this

func _init() -> void:
	Global.player = self
	

func _process(delta: float) -> void:
	if Input.is_action_pressed("sprint"):
		speed = sprint_speed
		acceleration = sprint_acceleration
	else:
		speed = normal_speed
		acceleration = normal_acceleration
		
	for area in $PlayerArea.get_overlapping_areas():
		if (not area.is_in_group("BarelyVisible")) and (not area.is_in_group("FullLight")):
			visible_level = Types.VisibleLevels.Dark
		
	if $PlayerArea.get_overlapping_areas() == []:
		visible_level = Types.VisibleLevels.Dark
		
	print(visible_level)
		
func _physics_process(delta: float) -> void:
	# movement code
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction = direction.normalized()
	
	velocity = velocity.move_toward(direction * speed, acceleration * delta)
		
	velocity = move_and_slide(velocity)


func _on_PlayerArea_area_entered(area: Area2D) -> void:
	if area.is_in_group("FullLight"):
		visible_level = Types.VisibleLevels.FullLight
	elif area.is_in_group("BarelyVisible"):
		visible_level = Types.VisibleLevels.BarelyVisible


	
