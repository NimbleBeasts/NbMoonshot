tool
class_name Player
extends KinematicBody2D

#enum LightLevels {Dark = 0, BarelyVisible = 1, FullLight = 2}
const visibilityLevelsModulations = ["#444444", "#555555", "#888888", "#ffffff"]
enum Directions {RIGHT, LEFT}
#export(Array, Color, RGBA) var visibilityLevelsModulations = ["#555555", "#888888", "#ffffff"]

# movement variables
export var normal_speed: int = 80
export var normal_acceleration: int = 600
export var sprint_speed: int = 120
export var sprint_acceleration: int = 2500
export var duckSpeed: int = 40
export var duckAcceleration: int = 300
export var gravity: int = 800
export (Directions) var startingDirection: int setget setStartingDirection

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
var movementBlocked = false
var blockEntireInput = false
var guardToPickup
var currentInteractable
var forcedDuckState: bool
var canInteract: bool = true

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

var isSneaking: bool = false
var applyGravity: bool = false


var footstepSounds = [
	preload("res://Assets/SFX/sfx_footstep_new1.wav"),
	preload("res://Assets/SFX/sfx_footstep_new2.wav"),
	preload("res://Assets/SFX/sfx_footstep_new3.wav"),
	preload("res://Assets/SFX/sfx_footstep_new4.wav")
]

onready var travel_tween: Tween = $TravelTween
onready var travel_raycast_down: RayCast2D = $TravelRayCasts/RayCast2DDown
onready var travel_raycast_up: RayCast2D = $TravelRayCasts/RayCast2DUp
onready var stun_raycast: RayCast2D = $Flippable/StunRayCast
onready var sprite: Sprite = $Flippable/PlayerSprite
onready var camera: Camera2D = $Camera2D
onready var guardPickup: Area2D = $GuardPickup
onready var weaponHandler: Node2D = $WeaponHandler
onready var animPlayer: AnimationPlayer = $AnimationPlayer
onready var itemPickup = $ItemPickup


func _init() -> void:
	Global.player = self


func _ready() -> void:
	do_upgrade_stuff()
	$WeaponHandler/Taser.stunBatteryLevel = stun_battery_level
	add_to_group("Upgradable")
	set_state(Types.PlayerStates.Normal)

	# signal connections
	#warning-ignore-all:return_value_discarded
	Events.connect("minigame_entered", self,  "_on_minigame_entered")
	Events.connect("hud_note_exited", self, "_on_hud_note_exited")
	Events.connect("hud_note_show", self, "_on_hud_note_showed")
	Events.connect("player_block_movement", self, "onBlockPlayerMovement")
	Events.connect("player_block_input", self, "onBlockPlayerInput")
	Events.connect("player_unblock_input", self, "onUnblockPlayerInput")
	Events.connect("player_unblock_movement", self, "onUnblockPlayerMovement")
	Events.connect("game_over", self, "onGameOver")
	Events.connect("player_upgrades_do", self, "do_upgrade_stuff")
	Events.connect("player_state_set", self, "set_state")
	Events.connect("player_animation_change", $AnimationPlayer, "play")


	$AnimationPlayer.play("idle")
	$PlayerArea.connect("area_entered", $ItemPickup, "onPlayerAreaEntered")
	$PlayerArea.connect("area_exited", $ItemPickup, "onPlayerAreaExited")
	$PlayerArea.connect("area_entered", self, "onPlayerAreaEntered")
	$PlayerArea.connect("area_exited", self, "onPlayerAreaExited")
	$AnimationPlayer.connect("animation_finished", $ItemPickup, "onAnimationFinished")
	$AnimationPlayer.connect("animation_finished", guardPickup, "onAnimationFinished")
	$GroundDetection.connect("apply_gravity", self, "setApplyGravity", ["dummy", true])
	$GroundDetection.connect("body_entered", self, "setApplyGravity", [false])

	# Initial set taser level
	yield(get_tree(), "idle_frame")
	Events.emit_signal("player_taser_fired", stun_battery_level)


func setStartingDirection(newDirection: int) -> void:
	startingDirection = newDirection
	$Flippable.scale.x = 1 if newDirection == Directions.RIGHT else -1


func _process(_delta: float) -> void:
	if Engine.editor_hint:
		return
	Global.screen_center = global_position

	if state != Types.PlayerStates.WallDodge or isSneaking:
		update_light_level()

	# wall dodging
	walldodgeInput()

	# ducking 
	duckInput()

	# duck walking animation
	if state == Types.PlayerStates.Duck and abs(velocity.x) != 0:
		$AnimationPlayer.play("duck_walk")
	elif state == Types.PlayerStates.Duck and abs(velocity.x) == 0:
		$AnimationPlayer.play("duck")
	
	# wall dodging animation
	if state == Types.PlayerStates.WallDodge and abs(velocity.x) != 0:
		$AnimationPlayer.play("dodge_walk")
		isSneaking = true
	elif state == Types.PlayerStates.WallDodge and abs(velocity.x) == 0:
		$AnimationPlayer.play("dodge")
		isSneaking = false


func walldodgeInput() -> void:
	if blockEntireInput:
		return
	if Input.is_action_pressed("wall_dodge") and not forcedDuckState:
		setVisibleLevel(int(max(light_level - 1, 0)))
		set_state(Types.PlayerStates.WallDodge)
		movementBlocked = true if (not has_sneak_upgrade) else false
	if Input.is_action_just_released("wall_dodge") and state == Types.PlayerStates.WallDodge and not forcedDuckState:
		setVisibleLevel(light_level)
		set_state(Types.PlayerStates.Normal)
		isSneaking = false


func duckInput() -> void:
	if blockEntireInput:
		return
	if movementBlocked:
		return
	if Input.is_action_pressed("duck") and not travel_raycast_down.is_colliding():
		set_state(Types.PlayerStates.Duck)
	if Input.is_action_just_released("duck") and state == Types.PlayerStates.Duck and not forcedDuckState:
		set_state(Types.PlayerStates.Normal)


func movementInput() -> void:
	if blockEntireInput:
		direction.x = 0
		return
	# changed between speeds depending on whether sprinting or not
#	if Input.is_action_pressed("sprint") and canSprint and state == Types.PlayerStates.Normal:
#		speed = sprint_speed
#		acceleration = sprint_acceleration
	if not Input.is_action_just_pressed("sprint") and state == Types.PlayerStates.Normal:
		speed = normal_speed
		acceleration = normal_acceleration

	if not movementBlocked:
		direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		direction = direction.normalized()
		updateFlip()
	else:
		direction = Vector2(0,0)


func _physics_process(delta: float) -> void:
	if Engine.editor_hint:
		return
	if applyGravity:
		var currentAnim = animPlayer.current_animation
		if currentAnim != "jump_up" and currentAnim != "jump_down" and currentAnim != "ladder":
			velocity.y += gravity * delta
			velocity.x = 16
	else:
		movementInput()	
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
	velocity = move_and_slide(velocity)
	
	$Label.set_text(str(abs(velocity.x)))
	if abs(velocity.x) == 0:
		animation_change("idle")
	else:
		animation_change("walk")
	
	# playing footstep sound
#	if velocity.x != 0 and playFootstepSound:
#		playFootstepSound = false
#		if state == Types.PlayerStates.Normal:
#			Events.emit_signal("play_sound", "player_footstep")
#		elif (state == Types.PlayerStates.Duck or state == Types.PlayerStates.WallDodge):
#			Events.emit_signal("play_sound", "player_crouch_footstep")

	# print("Movement blocked: %s, entire input blocked: %s" % [movementBlocked, blockEntireInput])


func update_light_level() -> void:
	# if there are no overlapping areas, just set light_level to dark
	# this works because the detecting area and the light areas are in their own collision layer
	var target_light_level = Types.LightLevels.Dark

	if not $PlayerLightArea.monitoring:
		return
	
	for area in $PlayerLightArea.get_overlapping_areas():
		if area.is_in_group("FullLight"):
			if area.get_parent().isOn():
				target_light_level = Types.LightLevels.FullLight
		elif area.is_in_group("BarelyVisible"):
			if area.get_parent().isOn():
				target_light_level = Types.LightLevels.BarelyVisible

	set_light_level(target_light_level)


				
func do_upgrade_stuff() -> void:
	# if/ else go brrrrrrrr

	# taser battery
	if Types.UpgradeTypes.Taser_Extended_Battery in Global.gameState.playerUpgrades:
		stun_battery_level = extended_stun_battery
	else:
		stun_battery_level = normal_stun_battery

	# stun duration
#	if Types.UpgradeTypes.Taser_Voltage in Global.gameState.playerUpgrades:
#		stun_duration = extended_stun_duration
#	else:
	stun_duration = normal_stun_duration

	# sneak upgrade
	has_sneak_upgrade = Types.UpgradeTypes.Sneak in Global.gameState.playerUpgrades
	
	if Types.UpgradeTypes.Fitness_Level2 in Global.gameState.playerUpgrades:
		normal_speed = 100
	else:
		normal_speed = 80

	
# Event Hooks
func _on_minigame_entered(_type: int) -> void:
	$AnimationPlayer.play("action")
	movementBlocked = true
	blockEntireInput = true
	if not forcedDuckState:
		set_state(Types.PlayerStates.Normal)


func _on_hud_note_exited(_d) -> void:
	blockEntireInput = false
	movementBlocked = false

func _on_hud_note_showed(_d, _type: int, _text: String) -> void:
	blockEntireInput = true
	movementBlocked = true
	# set_state(Types.PlayerStates.Normal)


func onBlockPlayerMovement() -> void:
	movementBlocked = true
	# set_state(Types.PlayerStates.Normal)

	
func onUnblockPlayerMovement() -> void:
	movementBlocked = false

func onBlockPlayerInput() -> void:
	blockEntireInput = true
	movementBlocked = true

func onUnblockPlayerInput() -> void:
	blockEntireInput = false


# use this function to set light_level instead of directly changing it
func set_light_level(value: int) -> void:
	if light_level != value:
		light_level = value
		# updates visible level when updating light_level
		# this is why a custom setter function is needed, may forgot to set visible level and
		# will fuk everything up
		setVisibleLevel(light_level)
		updateModulate()
	
func updateModulate():
	sprite.modulate = Color(visibilityLevelsModulations[visible_level])
	
# use this function to set state
func set_state(value: int) -> void:
	if state != value:
		state = value
		Events.emit_signal("player_state_changed", state)
		canInteract = state != Types.PlayerStates.DraggingGuard and state != Types.PlayerStates.DraggingItem
		match state:
			Types.PlayerStates.Normal:
				changeColliderState(true)
				$ItemPickup.dropCurrentItem()
				sprite.show()
				guardPickup.stopDragging()
				itemPickup.dropCurrentItem()
				speed = normal_speed
				acceleration = normal_acceleration
				$AnimationPlayer.play("idle")
				movementBlocked = false
				blockEntireInput = false
				enableNormalColliders()
			Types.PlayerStates.Duck:
				sprite.show()
				$GuardPickup.stopDragging()
				itemPickup.dropCurrentItem(false)
				speed = duckSpeed
				acceleration = duckAcceleration
				enableDuckColliders()
			Types.PlayerStates.WallDodge:
				sprite.show()
				enableNormalColliders()
				$GuardPickup.stopDragging()
				itemPickup.dropCurrentItem(false)
				speed = duckSpeed
				acceleration = duckAcceleration
			Types.PlayerStates.DraggingGuard:
				sprite.show()
				enableNormalColliders()
				speed = duckSpeed
				acceleration = duckAcceleration
			Types.PlayerStates.DraggingItem:
				sprite.show()
				enableNormalColliders()
				speed = duckSpeed
				acceleration = duckAcceleration
			Types.PlayerStates.InCloset:
				sprite.hide()
				changeColliderState(false)
				movementBlocked = true
				blockEntireInput = true

# Change animation
func animation_change(to: String) -> void:
	if $AnimationPlayer.current_animation != to:
		
		if $AnimationPlayer.current_animation == "idle" and to == "walk" or \
			$AnimationPlayer.current_animation == "walk" and to == "idle":
			$AnimationPlayer.play(to)


func _on_AnimationPlayer_animation_finished(anim_name):
	# Only non-looped animation will reach this point
	match anim_name:
		"lose":
			Global.game_manager.reloadLevel()
			return
		"walk":
			#Randomize Audio
			var randomNumbers = [Global.prng() % footstepSounds.size(), Global.prng() % footstepSounds.size()]
			if not $PlayerSounds/Footstep1.playing:
				$PlayerSounds/Footstep1.stream = footstepSounds[randomNumbers[0]]
			if not $PlayerSounds/Footstep2.playing:
				$PlayerSounds/Footstep2.stream = footstepSounds[randomNumbers[1]]
			$AnimationPlayer.play("walk")
		"throw":
			movementBlocked = false
		"throw_load":
			return

	$AnimationPlayer.play("idle")
	



func onGameOver() -> void:
	set_process(false)
	set_physics_process(false)
	movementBlocked = true
	$AnimationPlayer.play("lose")
	Events.emit_signal("hud_game_over")


func setVisibleLevel(value: int) -> void:
	if visible_level != value:
		visible_level = value
		Events.emit_signal("visible_level_changed", visible_level)
		updateModulate()

func enableNormalColliders() -> void:
	get_tree().set_group("DuckColliders", "disabled", true)
	get_tree().set_group("NormalColliders", "disabled", false)


func enableDuckColliders() -> void:
	get_tree().set_group("DuckColliders", "disabled", false)
	get_tree().set_group("NormalColliders", "disabled", true)


func updateFlip() -> void:
	if direction.x != 0:
		$Flippable.scale.x = direction.x


func changeColliderState(enabled: bool) -> void:
	$CollisionShape2D.set_deferred("disabled", not enabled)
	$DuckCollisionShape2D.set_deferred("disabled", not enabled)
	$PlayerLightArea.set_deferred("monitoring", enabled)
	$PlayerArea.set_deferred("monitoring", enabled)
	
func onPlayerAreaEntered(area: Area2D) -> void:
	if area.is_in_group("Interactable"):
		currentInteractable = area
	
func onPlayerAreaExited(area: Area2D) -> void:
	if currentInteractable == area:
		currentInteractable = null
		
func setApplyGravity(_dummyargument, to: bool):
	if applyGravity != to:
		applyGravity = to
		if not applyGravity:
			$PlayerSounds/BodyFall.play()


