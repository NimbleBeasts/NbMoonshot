class_name Player
extends KinematicBody2D

#enum LightLevels {Dark = 0, BarelyVisible = 1, FullLight = 2}
const visibilityLevelsModulations = ["#707070", "#989898", "#ffffff"]

# movement variables
export var normal_speed: int = 80
export var normal_acceleration: int = 600
export var sprint_speed: int = 160
export var sprint_acceleration: int = 2500

# upgrade export variables
export var normal_stun_battery: int = 3
export var extended_stun_battery: int = 5
export var normal_stun_duration: float = 4.0
export var extended_stun_duration: float = 7.0
export var normal_sprint_duration: float = 3.0
export var extended_sprint_duration: float = 6.0
export var stamina_replenish_duration: float = 3.0

var direction: Vector2
var velocity: Vector2
var speed: int = normal_speed
var acceleration: int = normal_acceleration
var block_input: bool = false
var can_move = true

#  Use Types.LightLevels enum for both of these. Light level is in which light the player is in
# and visible_level is actual visibility of player to guards and camera with wall dodging and other benefits
var light_level: int = -1 #Types.LightLevels.FullLight
var visible_level: int = light_level
var state: int = Types.PlayerStates.Normal
var colliding_with_travel: bool = false
var stun_battery_level: int = 3
var stun_duration: float = 4.0
var has_sneak_upgrade: bool = false
var sprint_duration: float
var canSprint: bool

onready var travel_tween: Tween = $TravelTween
onready var travel_raycast_down: RayCast2D = $TravelRayCasts/RayCast2DDown
onready var travel_raycast_up: RayCast2D = $TravelRayCasts/RayCast2DUp
onready var stun_raycast: RayCast2D = $StunRayCast
onready var player_sprite: Sprite = $PlayerSprite
onready var camera: Camera2D = $Camera2D


func _init() -> void:
	Global.player = self


func _ready() -> void:
	# sprint upgrade
	canSprint = Types.UpgradeTypes.Fitness_Level2 in Global.gameState.playerUpgrades
	add_to_group("Upgradable")
	do_upgrade_stuff()

	# signal connections
	#warning-ignore-all:return_value_discarded
	Events.connect("minigame_entered", self,  "_on_minigame_entered")
	Events.connect("minigame_exited", self, "_on_minigame_exited")
	Events.connect("interacted_with_npc", self, "_on_interacted_npc")
	Events.connect("npc_interaction_stopped", self, "_on_npc_interaction_stopped")
	Events.connect("hud_note_exited", self, "_on_hud_note_exited")
	Events.connect("hud_note_show", self, "_on_hud_note_showed")

	$AnimationPlayer.play("idle")

	# Initial set taser level
	Events.emit_signal("taser_fired", stun_battery_level)


func _process(_delta: float) -> void:
	# changed between speeds depending on whether sprinting or not
	if Input.is_action_pressed("sprint") and canSprint:
		speed = sprint_speed
		acceleration = sprint_acceleration
	else:
		speed = normal_speed
		acceleration = normal_acceleration
			

	update_light_level()
		
	# wall dodging
	if Input.is_action_pressed("wall_dodge"):
		set_light_level(max(light_level - 1, 0))
		set_state(Types.PlayerStates.WallDodge)
		$AnimationPlayer.play("dodge")
		block_input = true if (not has_sneak_upgrade) else false
	elif Input.is_action_just_released("wall_dodge"):
		visible_level = light_level
		set_state(Types.PlayerStates.Normal)

	# ducking 
	if Input.is_action_pressed("duck") and not travel_raycast_down.is_colliding():
		set_state(Types.PlayerStates.Duck)
		$AnimationPlayer.play("duck")
		block_input = true 
	elif Input.is_action_just_released("duck"):
		set_state(Types.PlayerStates.Normal)

	
func _physics_process(delta: float) -> void:
	# movement code
	if not block_input:
		direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		
		# Flip sprite if necessary
		if direction.x == -1 and player_sprite.flip_h == false:
			player_sprite.flip_h = true
			stun_raycast.cast_to *= Vector2(-1, 1)
		elif direction.x == 1 and player_sprite.flip_h == true:
			player_sprite.flip_h = false
			stun_raycast.cast_to *= Vector2(-1, 1)

		direction = direction.normalized()
	else:
		direction = Vector2(0,0)
	
	velocity = velocity.move_toward(direction * speed, acceleration * delta)
	velocity = move_and_slide(velocity)
	
	$Label.set_text(str(abs(velocity.x)))
	if abs(velocity.x) == 0:
		animation_change("idle")
	else:
		animation_change("walk")
		
	# Traveling up and down
	# Only needs to check if the respective direction key for each raycast is pressed
	# means only need to check if up is pressed when up raycast is colliding and vice versa
	# Can't use elif since both of these can be true at same time
	if travel_raycast_down.is_colliding():
		var thin_area := travel_raycast_down.get_collider() as ThinArea
		if thin_area:
			if Input.is_action_just_pressed("travel_down"):
				travel(thin_area.destination_down_position.y)
				$AnimationPlayer.play("jump_down")
				
	if travel_raycast_up.is_colliding():
		var thin_area := travel_raycast_up.get_collider() as ThinArea
		if thin_area:
			# Tweening
			if Input.is_action_just_pressed("travel_up"):
				travel(thin_area.destination_up_position.y)
				$AnimationPlayer.play("jump_up")
	
	# stunning
	if state == Types.PlayerStates.Normal and stun_battery_level > 0 :
		stunning()
		

func update_light_level() -> void:
	# if there are no overlapping areas, just set light_level to dark
	# this works because the detecting area and the light areas are in their own collision layer
	#if $PlayerLightArea.get_overlapping_areas() == []:
	set_light_level(Types.LightLevels.Dark)
	#	return
	
	# this will only run if light area is actually colliding with a light because of the return
	# this area and the lights have their own collision layer
	for area in $PlayerLightArea.get_overlapping_areas():
		if area.is_in_group("FullLight"):
			if area.get_parent().isOn():
				set_light_level(Types.LightLevels.FullLight)
		elif area.is_in_group("BarelyVisible"):
			if area.get_parent().isOn():
				set_light_level(Types.LightLevels.BarelyVisible)

	
func travel(target_pos: float) -> void:
	# just tweening position
	#warning-ignore:return_value_discarded
	travel_tween.interpolate_property(self, "global_position:y", global_position.y, 
			target_pos, 0.2, Tween.TRANS_LINEAR)
	#warning-ignore:return_value_discarded
	travel_tween.start()
	# emits small noise
	Events.emit_signal("audio_level_changed", Types.AudioLevels.SmallNoise, global_position)
	set_state(Types.PlayerStates.Normal)
	

func stunning() -> void:
	if Input.is_action_just_pressed("stun"):
		$AnimationPlayer.play("taser")
		if stun_raycast.is_colliding():
			var hit = stun_raycast.get_collider()		
			
			if hit.get_script() == Guard:
				print("Tazerd guard")
				var guard := hit as Guard
				if (guard) and (not guard.state == Types.GuardStates.Stunned):
					guard.stun(stun_duration)
					stun_battery_level -= 1
					Events.emit_signal("taser_fired", stun_battery_level)
			if hit.get_script() == Doll:
				print("Stunning doll")
				var doll := hit as Doll
				doll.stun(stun_duration)
				stun_battery_level -= 1
				Events.emit_signal("taser_fired", stun_battery_level)

				
func do_upgrade_stuff() -> void:
	# if/ else go brrrrrrrr

	# taser battery
	if Types.UpgradeTypes.Taser_Extended_Battery in Global.gameState.playerUpgrades:
		print("has taser battery upgrade")
		stun_battery_level = extended_stun_battery
	else:
		stun_battery_level = normal_stun_battery

	# stun duration
	if Types.UpgradeTypes.Taser_Voltage in Global.gameState.playerUpgrades:
		print("has taser voltage upgrade")
		stun_duration = extended_stun_duration
	else:
		stun_duration = normal_stun_duration

	# sneak upgrade
	if Types.UpgradeTypes.Sneak in Global.gameState.playerUpgrades:
		print("has sneak upgrade")
		has_sneak_upgrade = true
	else:
		has_sneak_upgrade = false


# Event Hooks
func _on_minigame_entered(_type: int) -> void:
	$AnimationPlayer.play("action")
	block_input = true
	print("Minigame entered")

	
func _on_minigame_exited(_type: int) -> void:
	block_input = false
	print("Minigame exited")

# I feel like I can connect all of these to two functions for blocking and unblocking input because they all do the same thing anyway
func _on_interacted_npc(_npc: Node) -> void:
	block_input = true 

func _on_npc_interaction_stopped(_npc: Node) -> void:
	block_input = false

func _on_hud_note_exited() -> void:
	block_input = false

func _on_hud_note_showed(_type: int, _text: String) -> void:
	block_input = true


# use this function to set light_level instead of directly changing it
func set_light_level(value: int) -> void:
	if light_level != value:
		light_level = value
		# updates visible level when updating light_level
		# this is why a custom setter function is needed, may forgot to set visible level and
		# will fuk everything up
		visible_level = light_level
		$PlayerSprite.modulate = Color(visibilityLevelsModulations[visible_level])
		Events.emit_signal("light_level_changed", light_level)
	
	
# use this function to set state
func set_state(value: int) -> void:
	if state != value:
		state = value
		match state:
			Types.PlayerStates.Normal:
				$AnimationPlayer.play("idle")
				block_input = false

# Change animation
func animation_change(to: String) -> void:
	if $AnimationPlayer.current_animation != to:
		
		if $AnimationPlayer.current_animation == "idle" and to == "walk" or \
			$AnimationPlayer.current_animation == "walk" and to == "idle":
			#print("change to:" + to)
			$AnimationPlayer.play(to)
		

func _on_AnimationPlayer_animation_finished(_anim_name):
	# Only non-looped animation will reach this point
	$AnimationPlayer.play("idle")
