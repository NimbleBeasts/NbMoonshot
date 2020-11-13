class_name Stealable
extends Node2D

export var queue_free_on_succeed: bool = false
var can_steal: bool = false


func _ready() -> void:
	# connects all needed signals
	$StealArea.connect("body_entered", self, "_on_StealArea_body_entered")
	$StealArea.connect("body_exited", self, "_on_StealArea_body_exited")
	$NotifierArea.connect("body_entered", self, "_on_NotifierArea_body_entered")
	$NotifierArea.connect("body_exited", self, "_on_NotifierArea_body_exited")

	set_process(false)


func _process(delta: float) -> void:
	if $MinigameSpawner.minigame_succeeded:
		# you can change level now if you go to extraction zone
		Global.game_manager.getCurrentLevel().can_change_level = true
		if queue_free_on_succeed:
			queue_free()


func _on_StealArea_body_entered(body: Node) -> void:
	if body is Player:
		can_steal = true
		set_process(true)

		
func _on_StealArea_body_exited(body: Node) -> void:
	if body is Player:
		can_steal = false
		set_process(false)

func _on_NotifierArea_body_entered(body: Node) -> void:
	if body is Player:
		$Notifier.popup(Types.NotifierTypes.Exclamation)


func _on_NotifierArea_body_exited(body: Node) -> void:
	if body is Player:
		$Notifier.remove()