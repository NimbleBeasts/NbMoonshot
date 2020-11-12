class_name Guard
extends KinematicBody2D

export var speed: int = 50
export var direction_change_time: float = 2
export var starting_direction: Vector2
export var time_to_sure_detection: float = 1.5
export var stun_duration: float = 2
export var audio_suspect_distance: int = 150
export var normal_time_to_alarm: float = 1.5
export var extended_time_to_alarm: float = 3.5


var velocity: Vector2
var direction: Vector2
var state: int = Types.GuardStates.Wander # Types.GuardStates
var player_in_los: bool = false
var check_for_stunned: bool = true

var guard_normal_texture: Texture = preload("res://Assets/Guards/Guard.png")
var guard_green_texture: Texture = preload("res://Assets/Guards/GuardGreen.png")

onready var los_area: Area2D = $Flippable/LineOfSight


func _ready() -> void:
	Global.addUpgrade(Types.UpgradeTypes.Distraction)
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
	$DirectionChangeTimer.start()
	direction = starting_direction
	Events.connect("audio_level_changed", self, "_on_audio_level_changed")
	$Flippable/LineOfSight.connect("body_entered", self, "_on_LineOfSight_body_entered")
	#TODO: level setting if blue (western) or green guards (eastern) -> change sprite accordingly


func _process(delta: float) -> void:
	velocity = direction * speed
	velocity = move_and_slide(velocity)
	update_flip()
	match state:
		Types.GuardStates.PlayerDetected, Types.GuardStates.Suspect:
			direction = Vector2(0,0)
			$DirectionChangeTimer.stop()
	
	# the player could be in dark visible level when the overlap happens and it would check according to that
	# then the player could move to full light and it wouldn't get called unless it's a new overlap
	# so we have to do set a bool on area entered and check in _process
	if player_in_los and state != Types.GuardStates.Stunned:
		match Global.player.visible_level:

			Types.LightLevels.FullLight:
				set_state(Types.GuardStates.PlayerDetected)
				player_in_los = false
			Types.LightLevels.BarelyVisible:
				set_state(Types.GuardStates.Suspect)
			Types.LightLevels.Dark:
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

func unstun() -> void:
	$DirectionChangeTimer.start()
	$Flippable/LineOfSight/CollisionPolygon2D.set_deferred("disabled", false)
	# can check for stunned bodies again
	get_tree().set_group("Guard", "check_for_stunned", true)
	$Notifier.remove()

	
func _on_DirectionChangeTimer_timeout():
	if state == Types.GuardStates.Wander:
		change_direction()
	
	
func _on_LineOfSight_area_entered(area: Area2D) -> void:
	# detecting player
	if area.is_in_group("PlayerArea") and state != Types.GuardStates.Stunned:
		player_in_los = true


func _on_LineOfSight_body_entered(body: Node) -> void:
	if body is TileMap:
		change_direction()

		
# this gets started when this guard's state changes to PlayerDetected
# on timeout, meaning if not stunned within this time, the detection level of player gets to Sure
func _on_SureDetectionTimer_timeout() -> void:
	Events.emit_signal("player_detected", Types.DetectionLevels.Sure)
	$AnimationPlayer.play("alarm")


func _on_StunDurationTimer_timeout() -> void:
	unstun()
	$AnimationPlayer.play("stand_up")


func _on_LineOfSight_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		player_in_los = false


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
		match state:
			Types.GuardStates.PlayerDetected:
				if $SureDetectionTimer.is_stopped():
					$SureDetectionTimer.start()
				Events.emit_signal("player_detected", Types.DetectionLevels.Possible)
				$AnimationPlayer.play("suspicious")
			Types.GuardStates.Suspect:
				direction = Vector2(0,0)
				print(name + " has suspicion")
				$Notifier.popup(Types.NotifierTypes.Question)
			Types.GuardStates.Wander:
				$Notifier.remove()
			
				
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
			pass
		"stand_up":
			set_state(Types.GuardStates.Wander)
			direction = starting_direction
