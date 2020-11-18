class_name Guard
extends KinematicBody2D

signal stop_movement
signal start_movement

export var speed: int = 50
export var direction_change_time: float = 2
export var starting_direction: Vector2
export var time_to_sure_detection: float = 1.5
export var stun_duration: float = 2
export var audio_suspect_distance: int = 150
export var normal_time_to_alarm: float = 1.5
export var extended_time_to_alarm: float = 3.5
export var playerSuspectDistance: int = 24
export var playerDetectDistance: int = 16

var velocity: Vector2
var direction: Vector2
var state: int = Types.GuardStates.Wander # Types.GuardStates
var player_in_los: bool = false
var check_for_stunned: bool = true
var player_detected: bool = false

var guard_normal_texture: Texture = preload("res://Assets/Guards/Guard.png")
var guard_green_texture: Texture = preload("res://Assets/Guards/GuardGreen.png")
var guardPathLine

onready var los_area: Area2D = $Flippable/LineOfSight
onready var player = Global.player


func _ready() -> void:
	add_to_group("Upgradable")
	do_upgrade_stuff()
	
	# sets sprite texture on level type
	match Global.game_manager.getCurrentLevel().level_type:
		Types.LevelTypes.Western:
			$Flippable/Sprite.texture = guard_normal_texture
		Types.LevelTypes.Eastern:
			$Flippable/Sprite.texture = guard_green_texture 

	# sets the wait_time to the exported variable
	$DirectionChangeTimer.wait_time = direction_change_time
	$SureDetectionTimer.wait_time = time_to_sure_detection

	if not has_node("GuardPathLine"):
		$DirectionChangeTimer.start()
		direction = starting_direction
	else:
		direction = Vector2(0,0)
		guardPathLine = get_node("GuardPathLine")

	Events.connect("audio_level_changed", self, "_on_audio_level_changed")
	#warning-ignore:return_value_discarded


func _process(_delta: float) -> void:
	velocity = direction * speed
	velocity = move_and_slide(velocity)
		
	update_flip()
	detectPlayerIfClose()
	match state:
		Types.GuardStates.PlayerDetected, Types.GuardStates.Suspect, Types.GuardStates.Stunned:
			direction = Vector2(0,0)
			$DirectionChangeTimer.stop()
		Types.GuardStates.Wander:
			pass

			
	# the player could be in dark visible level when the overlap happens and it would check according to that
	# then the player could move to full light and it wouldn't get called unless it's a new overlap
	# so we have to do set a bool on area entered and check in _process
	if player_in_los and state != Types.GuardStates.Stunned:
		match player.visible_level:

			Types.LightLevels.FullLight:
				set_state(Types.GuardStates.PlayerDetected)
				player_in_los = false
			Types.LightLevels.BarelyVisible:
				if not player_detected: # only sets to suspect if hasn't detected player before
					set_state(Types.GuardStates.Suspect)
			Types.LightLevels.Dark:
				if not player_detected: # only sets to wander if hasn't detected player before
					set_state(Types.GuardStates.Wander)

				
	# checks for stunned bodies
	if check_for_stunned:
		for body in los_area.get_overlapping_bodies():
			if body.is_in_group("Guard"):
				if body.state == Types.GuardStates.Stunned:
					Events.emit_signal("player_detected", Types.DetectionLevels.Sure)
					check_for_stunned = false


	match state:
		Types.GuardStates.Wander:
			if not velocity.is_equal_approx(Vector2.ZERO):
				$AnimationPlayer.play("walk")
			else:
				$AnimationPlayer.play("idle")
		Types.GuardStates.Stunned:
			pass
		Types.GuardStates.Suspect:
			$AnimationPlayer.play("idle")


func change_direction() -> void:
	# flips the direction.x
	direction.x *= -1 


func detectPlayerIfClose() -> void:
	if player.global_position.distance_to(global_position) < playerDetectDistance and state != Types.GuardStates.Stunned:
		if player.state != Types.PlayerStates.WallDodge and not player_detected:
				guardPathLine.moveToPoint(player.global_position)
				$Notifier.popup(Types.NotifierTypes.Question)
				if player.global_position.distance_to(global_position) < playerSuspectDistance:
					set_state(Types.GuardStates.PlayerDetected)


# stun function.
func stun(duration: float) -> void:
	direction = Vector2(0,0)
	set_state(Types.GuardStates.Stunned)
	$Flippable/LineOfSight/CollisionPolygon2D.set_deferred("disabled", true)
	player_in_los = false
	$AnimationPlayer.play("tasered")
	# timer stuff
	$StunDurationTimer.start(duration)
	$DirectionChangeTimer.stop()
	$SureDetectionTimer.stop()
	$Notifier.remove()
	player_detected = false


func unstun() -> void:
	$DirectionChangeTimer.start()
	$Flippable/LineOfSight/CollisionPolygon2D.set_deferred("disabled", false)
	# can check for stunned bodies again
	get_tree().set_group("Guard", "check_for_stunned", true) # i have no idea if this works now, but i think it should
	$Notifier.remove()

	
func _on_DirectionChangeTimer_timeout():
	if state == Types.GuardStates.Wander:
		change_direction()
	
	
func _on_LineOfSight_body_entered(body: Node) -> void:
#	if body is TileMap: # changes direction when collide with tilemap
#		change_direction()
	if body.is_in_group("Player") and state != Types.GuardStates.Stunned:
		player_in_los = true
		

func _on_LineOfSight_body_exited(body):
	if body.is_in_group("Player"):
		player_in_los = false


#func _on_LineOfSight_area_exited(area: Area2D) -> void:
#	if area.is_in_group("PlayerArea"):
#		player_in_los = false


		
# this gets started when this guard's state changes to PlayerDetected
# on timeout, meaning if not stunned within this time, the detection level of player gets to Sure
func _on_SureDetectionTimer_timeout() -> void:
	$AnimationPlayer.play("alarm")


func _on_StunDurationTimer_timeout() -> void:
	unstun()
	$AnimationPlayer.play("stand_up")


# Event Hook: audio level changed. audio_pos is the position where the audio notification happened
func _on_audio_level_changed(audio_level: int, audio_pos: Vector2) -> void:
	match audio_level:
		Types.AudioLevels.LoudNoise:
			if audio_pos.distance_to(global_position) < audio_suspect_distance:
				set_state(Types.GuardStates.Suspect)

				
# use this function to set state instead of doing directly
func set_state(new_state) -> void:
	if state != new_state:
		state = new_state
		
		# Put stuff you want to do once when state changes here
		match new_state:
			Types.GuardStates.PlayerDetected:
				# starts sure timer
				if $SureDetectionTimer.is_stopped():
					$SureDetectionTimer.start()
				Events.emit_signal("player_detected", Types.DetectionLevels.Possible)
				player_detected = true
				$AnimationPlayer.play("suspicious")
				emit_signal("stop_movement")
				guardPathLine.stopAllMovement()
				
			Types.GuardStates.Suspect:
				guardPathLine.stopAllMovement()
				emit_signal("stop_movement")
				if not $Notifier.isShowing:
					$Notifier.popup(Types.NotifierTypes.Question)
			Types.GuardStates.Wander:
				$Notifier.remove()
				emit_signal("start_movement")
			Types.GuardStates.Stunned:
				emit_signal("stop_movement")
				
func update_flip() -> void:
	if direction.x != 0:
		$Flippable.scale.x = direction.x


func do_upgrade_stuff() -> void:
	if Types.UpgradeTypes.Distraction in Global.gameState.playerUpgrades:
		print("has distraction upgrade")
		time_to_sure_detection = extended_time_to_alarm
	else:
		time_to_sure_detection = normal_time_to_alarm


func _on_AnimationPlayer_animation_started(anim_name):
	if anim_name == "suspicious":
		$Notifier.popup(Types.NotifierTypes.Exclamation)


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"suspicious":
			$Notifier.remove()
		"alarm":
			Events.emit_signal("player_detected", Types.DetectionLevels.Sure)
		"stand_up":
			set_state(Types.GuardStates.Wander)
			emit_signal("start_movement")
			if not get_node_or_null("GuardPathLine"):
				direction = starting_direction

