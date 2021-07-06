class_name Minigame
extends Node2D

signal result_changed(result)

export (Types.Minigames) var minigame_type # this is for emitting correct type on minigame_entered signal

var result: int
var owner_obj # the door that owns this minigame
var is_open: bool = false
var canCloseMinigame: bool = true
var canOpenMinigame: bool = true
var tweenIsInUse: bool = false
var playerLastGuard

#warning-ignore:unused_class_variable
onready var tween: Tween = get_node_or_null("Tween") #TODO: not sure if needed
onready var newTween: Tween = Tween.new()
onready var player: Player = Global.player


func _ready() -> void:
	Events.connect("minigame_forcefully_close", self, "onForcefullyCloseMinigame")
	add_child(newTween)
	#warning-ignore:return_value_discarded
	newTween.connect("tween_all_completed", self, "_on_tween_all_completed")
	set_result(Types.MinigameResults.Doing)


func _process(_delta: float) -> void:
	if owner_obj == null:
		return
	if owner_obj.player_entered: # only can interact if player close to owner door
		if Input.is_action_just_pressed("interact") and not is_open and player.canInteract:
			open()
		
		# closes minigame if either close button is pressed OR
		if Input.is_action_just_pressed("cancel") and canCloseMinigame:
			close()

	
# Basically open and close minigame are just tweening the minigame position 
func open() -> void:
	if not tweenIsInUse:
		var screen_center: Vector2 = get_viewport_rect().size / 2
		# tweening position 
		#warning-ignore:return_value_discarded
		newTween.interpolate_property(self, "global_position", 
				global_position, screen_center, 0.2, Tween.TRANS_LINEAR)
		#warning-ignore:return_value_discarded
		newTween.start()
		tweenIsInUse = true
		if player.guardPickup.isDragging and player.guardPickup.object != null:
			playerLastGuard = player.guardPickup.object
		Events.emit_signal("minigame_entered", minigame_type)
		Events.emit_signal("player_guard_drop")
		Events.emit_signal("player_block_input")
		is_open = true


func close() -> void:
	if not tweenIsInUse:
		var screenCenter: Vector2 = get_viewport_rect().size / 2
		var screen_bottom_center: Vector2 = Vector2(screenCenter.x, screenCenter.y + 500)
		# tweening position 
		#warning-ignore:return_value_discarded
		newTween.interpolate_property(self, "global_position", 
				global_position, screen_bottom_center, 0.2, Tween.TRANS_LINEAR)
		#warning-ignore:return_value_discarded
		newTween.start()
		tweenIsInUse = true
		is_open = false
		# Emits signal
		Events.emit_signal("minigame_exited", result)
		Events.emit_signal("player_unblock_movement")
		Events.emit_signal("player_unblock_input")
		if playerLastGuard:
			player.guardPickup.object = playerLastGuard
			player.guardPickup.dragObject()
		# emit audio notification loud if fail minigame
		if result == Types.MinigameResults.Failed:
			Events.emit_signal("audio_level_changed", Types.AudioLevels.LoudNoise, owner_obj.global_position, self)

		
func set_result(value: int):
	#print("result: " + str(value))
	if result != value:
		result = value
		emit_signal("result_changed", result) # connects to the owner_obj object
		if result == Types.MinigameResults.Failed:
			playFailSound()		
		elif result == Types.MinigameResults.Succeeded:
			playSuccessSound()			


func playFailSound() -> void:
	Events.emit_signal("play_sound", "minigame_fail")


func playSuccessSound() -> void:
	Events.emit_signal("play_sound", "minigame_success")

	
func _on_tween_all_completed() -> void:
	tweenIsInUse = false
	if not is_open: # destroys minigame if tween close animation finishes
		queue_free()
		owner_obj.minigame = null
		Events.emit_signal("player_unblock_movement")

			
func onForcefullyCloseMinigame() -> void:
	close()

