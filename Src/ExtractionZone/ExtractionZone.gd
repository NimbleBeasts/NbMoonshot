extends Area2D

# All this script does is if player is close enough to be in area, and player clicks interact in input map
# changes level to exported variable

var player_entered: bool = false
export var has_level_index: bool = true
export var level_index: int = 0
export var next_boss_interacted_counter: int = 0


func _ready() -> void:
	set_process(false)
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and not has_level_index:
		Global.game_manager.loadNextQuest()
	elif Input.is_action_just_pressed("interact") and has_level_index:
		Global.game_manager.boss_interaction_counter = next_boss_interacted_counter
		Global.game_manager.unloadLevel()
		Global.game_manager.loadLevel(level_index)
		

func _on_body_entered(body: Node) -> void:
	if body is Player:
		player_entered = true
		set_process(true)


func _on_body_exited(body: Node) -> void:
	if body is Player:
		player_entered = false
		set_process(false)
