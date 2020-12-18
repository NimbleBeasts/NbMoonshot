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

onready var tween: Tween = get_node_or_null("Tween")
onready var newTween: Tween = Tween.new()


func _ready() -> void:
	Events.connect("forcefully_close_minigame", self, "onForcefullyCloseMinigame")
	add_child(newTween)
	#warning-ignore:return_value_discarded
	newTween.connect("tween_all_completed", self, "_on_tween_all_completed")
	set_result(Types.MinigameResults.Doing)


func _process(_delta: float) -> void:
	if owner_obj:
		if owner_obj.player_entered: # only can interact if player close to owner door
			if Input.is_action_just_pressed("interact") and not is_open:
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
		# Emits signal
		Events.emit_signal("minigame_entered", minigame_type)
		Events.emit_signal("block_player_movement")
		is_open = true
		#print("open minigame")


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
		Events.emit_signal("unblock_player_movement")
		# emit audio notification loud if fail minigame
		if result == Types.MinigameResults.Failed:
			Events.emit_signal("audio_level_changed", Types.AudioLevels.LoudNoise, owner_obj.global_position, self)
		#print('closed minigame')

		
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
		Events.emit_signal("unblock_player_movement")

			
func onForcefullyCloseMinigame() -> void:
	close()
	
