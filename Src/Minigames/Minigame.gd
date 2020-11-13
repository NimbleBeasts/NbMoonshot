class_name Minigame
extends Node2D

signal result_changed(result)

export (Types.Minigames) var minigame_type # this is for emitting correct type on minigame_entered signal

var result: int
var owner_obj # the door that owns this minigame
var is_open: bool = false

onready var tween: Tween = $Tween

func _ready() -> void:
	#warning-ignore:return_value_discarded
	tween.connect("tween_all_completed", self, "_on_tween_all_completed")
	set_result(Types.MinigameResults.Doing)


func _process(_delta: float) -> void:
	if owner_obj:
		if owner_obj.player_entered: # only can interact if player close to owner door
			if Input.is_action_just_pressed("open_minigame"):
				open()
				
			if Input.is_action_just_pressed("close_minigame"):
				close()		
	
	
# Basically open and close minigame are just tweening the minigame position 
func open() -> void:
	var screen_center := get_viewport_rect().size / 2
	# tweening position 
	#warning-ignore:return_value_discarded
	tween.interpolate_property(self, "global_position", 
			global_position, screen_center, 0.2, Tween.TRANS_LINEAR)
	#warning-ignore:return_value_discarded
	tween.start()
	# Emits signal
	Events.emit_signal("minigame_entered", minigame_type)
	is_open = true


func close() -> void:
	var screen_bottom_center := Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y + 500)
	# tweening position 
	#warning-ignore:return_value_discarded
	tween.interpolate_property(self, "global_position", 
			global_position, screen_bottom_center, 0.2, Tween.TRANS_LINEAR)
	#warning-ignore:return_value_discarded
	tween.start()
	is_open = false
	# Emits signal
	Events.emit_signal("minigame_exited", result)
	# emit audio notification loud if fail minigame
	if result == Types.MinigameResults.Failed:
		Events.emit_signal("audio_level_changed", Types.AudioLevels.LoudNoise, owner_obj.global_position)


func set_result(value: int):
	print("result: " + str(value))
	if result != value:
		result = value
		emit_signal("result_changed", result) # connects to the owner_obj object
		
		
func _on_tween_all_completed() -> void:
	match result:
		Types.MinigameResults.Succeeded, Types.MinigameResults.Failed:
			queue_free()
