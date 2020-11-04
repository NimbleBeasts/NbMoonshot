extends Area2D

var player_entered: bool = false
onready var player: Player = Global.player

func _ready() -> void:
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")


func _process(delta: float) -> void:
	if player_entered:
		if Input.is_action_just_pressed("interact"):
			$Tween.interpolate_property(player, "global_position:y", player.global_position.y, 
					$Destination.global_position.y, 0.1, Tween.TRANS_LINEAR)
			$Tween.start()
		

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		player_entered = true
		

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		player_entered = false
