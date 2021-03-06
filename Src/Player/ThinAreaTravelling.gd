extends Node

export var travelTweenPath: NodePath
export var travelRayDownPath: NodePath
export var travelRayUpPath: NodePath
export var playerPath: NodePath
export var travelDurationNormal: float = 0.2
export var travelDurationLadder: float = 1

onready var travelRayDown: RayCast2D = get_node(travelRayDownPath)
onready var travelRayUp: RayCast2D = get_node(travelRayUpPath)
onready var player: Player = get_node(playerPath)
onready var travelTween: Tween = get_node(travelTweenPath)


func _ready() -> void:
	travelTween.connect("tween_all_completed", self, "onTravelTweenAllCompleted")


func _physics_process(delta: float) -> void:
	if player.blockEntireInput or player.movementBlocked:
		return
		
	
	# Can't use elif since both of these can be true at same time
	if travelRayDown.is_colliding() and player.state == Types.PlayerStates.Normal:
		var thinArea := travelRayDown.get_collider() as ThinArea
		
		var botAreaGood = true
		if thinArea == null:
			botAreaGood = false
		elif thinArea.disabled:
			botAreaGood = false
			
		if Input.is_action_just_pressed("travel_down") && botAreaGood:
			Events.emit_signal("player_guard_drop")
			Events.emit_signal("player_item_drop")
			var travelDuration: float
			var correctAnim: String
			if thinArea.isLadder:
				travelDuration = travelDurationLadder
				correctAnim = "ladder"
			else:
				travelDuration = travelDurationNormal
				correctAnim = "jump_down"
			travel(thinArea.destination_down_position, travelDuration)
			Events.emit_signal("player_block_input")
			Events.emit_signal("player_animation_change", correctAnim)
			get_parent().get_node("PlayerSounds/JumpDown").play()
			return

	if travelRayUp.is_colliding() and player.state == Types.PlayerStates.Normal:
		var thinArea := travelRayUp.get_collider() as ThinArea
		if thinArea == null:
			return
		elif thinArea.disabled:
			return
		# Tweening
		if Input.is_action_just_pressed("travel_up"):
			Events.emit_signal("player_guard_drop")
			Events.emit_signal("player_item_drop")
			var travelDuration: float
			var correctAnim: String
			if thinArea.isLadder:
				travelDuration = travelDurationLadder
				correctAnim = "ladder"
			else:
				travelDuration = travelDurationNormal
				correctAnim = "jump_up"
			travel(thinArea.destination_up_position, travelDuration)
			Events.emit_signal("player_block_input")
			Events.emit_signal("player_animation_change", correctAnim)
			get_parent().get_node("PlayerSounds/JumpUp").play()


func travel(targetPosition: Vector2, tweenDuration: float) -> void:
	# # just tweening position
	player.global_position.x = targetPosition.x
	travelTween.interpolate_property(player, "global_position", player.global_position,
		 targetPosition, tweenDuration, Tween.TRANS_LINEAR)
	travelTween.start()
	Events.emit_signal("audio_level_changed", Types.AudioLevels.SmallNoise, player.global_position, self)
	Events.emit_signal("player_state_set", Types.PlayerStates.Normal)


func onTravelTweenAllCompleted() -> void:
	# unblocking player input because it gets blocked when starting the tweening
	Events.emit_signal("player_unblock_input")
	Events.emit_signal("player_unblock_movement")
	# to rest player anim to idle
	Events.emit_signal("player_animation_change", "idle")
