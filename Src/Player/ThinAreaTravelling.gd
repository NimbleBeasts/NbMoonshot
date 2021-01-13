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
		if thinArea == null:
			return
		if Input.is_action_just_pressed("travel_down"):
			Events.emit_signal("drop_guard")
			Events.emit_signal("drop_current_item")
			var travelDuration: float
			var correctAnim: String
			if thinArea.isLadder:
				travelDuration = travelDurationLadder
				correctAnim = "ladder"
			else:
				travelDuration = travelDurationNormal
				correctAnim = "jump_down"
			travel(thinArea.destination_down_position, travelDuration)
			Events.emit_signal("block_player_input")
			Events.emit_signal("change_player_animation", correctAnim)
			Events.emit_signal("play_sound", "jump_down")


	if travelRayUp.is_colliding() and player.state == Types.PlayerStates.Normal:
		var thinArea := travelRayUp.get_collider() as ThinArea
		if thinArea == null:
			return
		# Tweening
		if Input.is_action_just_pressed("travel_up"):
			Events.emit_signal("drop_guard")
			Events.emit_signal("drop_current_item")
			var travelDuration: float
			var correctAnim: String
			if thinArea.isLadder:
				travelDuration = travelDurationLadder
				correctAnim = "ladder"
			else:
				travelDuration = travelDurationNormal
				correctAnim = "jump_up"
			travel(thinArea.destination_up_position, travelDuration)
			Events.emit_signal("block_player_input")
			Events.emit_signal("change_player_animation", correctAnim)
			Events.emit_signal("play_sound", "jump_up")


func travel(targetPosition: Vector2, tweenDuration: float) -> void:
	#Maybe tween the player first to target position 
	player.global_position.x = targetPosition.x
	# just tweening position
	travelTween.interpolate_property(player, "global_position:y", player.global_position.y, 
			targetPosition.y, tweenDuration, Tween.TRANS_LINEAR)
	travelTween.start()
	Events.emit_signal("audio_level_changed", Types.AudioLevels.SmallNoise, player.global_position, self)
	Events.emit_signal("set_player_state", Types.PlayerStates.Normal)


func onTravelTweenAllCompleted() -> void:
	# unblocking player input because it gets blocked when starting the tweening
	Events.emit_signal("unblock_player_input")
	Events.emit_signal("unblock_player_movement")
	# to rest player anim to idle
	Events.emit_signal("change_player_animation", "idle")
