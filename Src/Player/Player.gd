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
var colliding_with_travel: bool = false

onready var travel_tween: Tween = $TravelTween
onready var travel_raycast_down: RayCast2D = $TravelRayCasts/RayCast2DDown
onready var travel_raycast_up: RayCast2D = $TravelRayCasts/RayCast2DUp
onready var stun_raycast: RayCast2D = $StunRayCast


func _init() -> void:
	Global.player = self


func _ready() -> void:
	Events.connect("minigame_entered", self,  "_on_minigame_entered")
	Events.connect("minigame_exited", self, "_on_minigame_exited")		


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
	if Input.is_action_just_pressed("duck"):
		if state != Types.PlayerStates.Duck:
			set_state(Types.PlayerStates.Duck)
		elif state == Types.PlayerStates.Duck:
			set_state(Types.PlayerStates.Normal)
	
	
func _physics_process(delta: float) -> void:
	# movement code
	if can_move:
		direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		direction = direction.normalized()
	else:
		direction = Vector2(0,0)
	
	velocity = velocity.move_toward(direction * speed, acceleration * delta)
	velocity = move_and_slide(velocity)
	
	# Traveling up and down
	# Only needs to check if the respective direction key for each raycast is pressed
	# means only need to check if up is pressed when up raycast is colliding and vice versa
	# Can't use elif since both of these can be true at same time
	if travel_raycast_down.is_colliding():
		var thin_area := travel_raycast_down.get_collider() as ThinArea
		if thin_area:
			if Input.is_action_just_pressed("travel_down"):
				travel(thin_area.destination_down_position.y)
				
	if travel_raycast_up.is_colliding():
		var thin_area := travel_raycast_up.get_collider() as ThinArea
		if thin_area:
			# Tweening
			if Input.is_action_just_pressed("travel_up"):
				travel(thin_area.destination_up_position.y)
				
				
	# stunning guards
	if stun_raycast.is_colliding():
		var guard := stun_raycast.get_collider() as Guard
		if (guard) and (Input.is_action_just_pressed("stun")) and (not guard.is_stunned):
			guard.stun()
	
	
func check_if_dark() -> void:
	# if there are no overlapping areas, just set light_level to dark
	# this works because the detecting area and the light areas are in their own collision layer
	if $PlayerLightArea.get_overlapping_areas() == []:
		set_light_level(Types.LightLevels.Dark)
		return 


func travel(target_pos: float) -> void:
	# just tweening position
	travel_tween.interpolate_property(self, "global_position:y", global_position.y, 
			target_pos, 0.2, Tween.TRANS_LINEAR)
	travel_tween.start()
	# emits small noise
	Events.emit_signal("audio_notification", Types.AudioLevels.SmallNoise)
				

func _on_PlayerArea_area_entered(area: Area2D) -> void:
	if area.is_in_group("FullLight"):
		set_light_level(Types.LightLevels.FullLight)
	elif area.is_in_group("BarelyVisible"):
		set_light_level(Types.LightLevels.BarelyVisible)


func _on_minigame_entered(type: int) -> void:
	can_move = false


func _on_minigame_exited(type: int) -> void:
	can_move = true
	

# use this function to set light_level instead of directly changing it
func set_light_level(value: int) -> void:
	if light_level != value:
		light_level = value
		# updates visible level when updating light_level
		# this is why a custom setter function is needed, may forgot to set visible level and
		# will fuk everything up
		visible_level = value
		Events.emit_signal("light_level_changed", value)
	
	
# use this function to set state
func set_state(value: int) -> void:
	if state != value:
		state = value
		
