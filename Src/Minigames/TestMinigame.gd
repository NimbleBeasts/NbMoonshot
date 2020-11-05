class_name Minigame
extends Node2D

export (Types.Minigames) var minigame_type # this is for emitting correct type on minigame_entered signal

var result: int
var owner_door # the door that owns this minigame

onready var tween: Tween = $Tween

func _ready() -> void:
	result = Types.MinigameResults.Failed


func _process(delta: float) -> void:
	if owner_door.player_entered: # only can interact if player close to owner door
		if Input.is_action_just_pressed("open_minigame"):
			open()
			
		if Input.is_action_just_pressed("close_minigame"):
			close()		
	
	
# Basically open and close minigame are just tweening the minigame position 
func open() -> void:
	var screen_center: Vector2 = get_viewport_rect().size / 2
	# tweening position 
	tween.interpolate_property(self, "global_position", 
			global_position, screen_center, 0.2, Tween.TRANS_LINEAR)
	tween.start()
	# Emits signal
	Events.emit_signal("minigame_entered", minigame_type)


func close(minigame_result: int = Types.MinigameResults.Failed) -> void:
	var screen_bottom_center := Vector2(get_viewport_rect().size.x / 2,  get_viewport_rect().size.y + 500) #adds a bit for extra measure
	# tweening position 
	tween.interpolate_property(self, "global_position", 
			global_position, screen_bottom_center, 0.2, Tween.TRANS_LINEAR)
	tween.start()
	# Emits signal
	Events.emit_signal("minigame_exited", minigame_result)
	# emit audio notification loud if fail minigame
	if minigame_result == Types.MinigameResults.Failed:
		Events.emit_signal("audio_level_changed", Types.AudioLevels.LoudNoise)
