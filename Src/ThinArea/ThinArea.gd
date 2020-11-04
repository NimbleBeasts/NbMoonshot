extends Area2D

var player_entered: bool = false
onready var player = Global.player


func _ready() -> void:
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")


func _process(delta: float) -> void:
	if player_entered:
		if Input.is_action_just_pressed("travel_up"):
			Events.emit_signal("player_travel", $DestinationUp.global_position)
		elif Input.is_action_just_pressed("travel_down"):
			Events.emit_signal("player_travel", $DestinationDown.global_position)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerTravelTrigger"):
		player_entered = true
		

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerTravelTrigger"):
		player_entered = false
