extends Area2D

# All this script does is if player is close enough to be in area, and player clicks interact in input map
# changes level to exported variable

var player_entered: bool = false


func _ready() -> void:
	set_process(false)
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		Global.game_manager.loadNextQuest()


func _on_body_entered(body: Node) -> void:
	if body is Player:
		player_entered = true
		set_process(true)


func _on_body_exited(body: Node) -> void:
	if body is Player:
		player_entered = false
		set_process(false)
