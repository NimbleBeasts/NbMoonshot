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
var can_move: int = true

#  Use Types.LightLevels enum for both of these. Light level is in which light the player is in
# and visible_level is actual visibility of player to guards and camera with wall dodging and other benefits
var light_level: int = Types.LightLevels.Dark
var visible_level: int = light_level
var state: int = Types.PlayerStates.Normal


func _init() -> void:
	Global.player = self


func _process(delta: float) -> void:
	# changed between speeds depending on whether sprinting or not
	if Input.is_action_pressed("sprint"):
		speed = sprint_speed
		acceleration = sprint_acceleration
	else:
		speed = normal_speed
		acceleration = normal_acceleration
	
	check_if_dark()
	
	# wall dodging
	if Input.is_action_pressed("wall_dodge"):
		visible_level = light_level - 1
		set_state(Types.PlayerStates.WallDodge)
	elif Input.is_action_just_released("wall_dodge"):
		visible_level = light_level
		set_state(Types.PlayerStates.Normal)
	
	# ducking
	if Input.is_action_pressed("duck"):
		set_state(Types.PlayerStates.Duck)
	elif Input.is_action_just_released("duck"):
		set_state(Types.PlayerStates.Normal)
	
	
func _physics_process(delta: float) -> void:
	# movement code
	if can_move:
		direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		direction = direction.normalized()
	
	velocity = velocity.move_toward(direction * speed, acceleration * delta)
	velocity = move_and_slide(velocity)


func check_if_dark() -> void:
	# if there are no overlapping areas, just set light_level to dark
	if $PlayerArea.get_overlapping_areas() == []:
		set_light_level(Types.LightLevels.Dark)
		return 
	
	# checks all area to see if there are no barely visible and no full light areas 
	for area in $PlayerArea.get_overlapping_areas():
		if (not area.is_in_group("BarelyVisible")) and (not area.is_in_group("FullLight")):
			set_light_level(Types.LightLevels.Dark)


func _on_PlayerArea_area_entered(area: Area2D) -> void:
	if area.is_in_group("FullLight"):
		set_light_level(Types.LightLevels.FullLight)
	elif area.is_in_group("BarelyVisible"):
		set_light_level(Types.LightLevels.BarelyVisible)
	

# use this function to set light_level instead of directly changing it
func set_light_level(value: int) -> void:
	if light_level != value:
		light_level = value
		# updates visible level when updating light_level
		# this is why a custom setter function is needed, may forgot to set visible level and
		# will fuk everything up
		visible_level = value
	
	
# use this function to set state
func set_state(value: int) -> void:
	if state != value:
		state = value
