class_name Door
extends Area2D

export var connected_door_path: NodePath

var player_entered: bool = false

onready var connected_door: Door = get_node_or_null(connected_door_path)
onready var player: Player = Global.player


func _init() -> void:
	set_process(false)


func _ready() -> void:
	# connections
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")
	if not connected_door:
		print("No connect door for " + name)


func _process(delta: float) -> void:
	if player_entered:
		if Input.is_action_just_pressed("interact"):
			interact()
			

func interact() -> void:
	# teleports to connected door
	if connected_door:
		player.global_position = connected_door.get_node("PlayerTeleportPosition").global_position
	else:
		print("Trying to teleport but no connected door for " + name)
	
	
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		player_entered = true
		set_process(true)
		
		
func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		player_entered = false
		set_process(false)
