class_name MinigameDoor
extends Area2D

export (Types.Minigames) var type

var player_entered: bool = false
var minigame: Minigame
var minigame_scene

onready var current_scene: Node = get_tree().current_scene
onready var game_manager := get_node("/root/GameManager")


func _ready() -> void:
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")
	# sets minigame scene checking type
	
	match type:
		Types.Minigames.Test:
			minigame_scene = load("res://Src/Minigames/TestMinigame.tscn")
		Types.Minigames.Keypad:
			minigame_scene = load("res://Src/Minigames/KeypadMinigame/KeypadMinigame.tscn")


func _process(delta: float) -> void:
	if player_entered: # if player is near
		if Input.is_action_just_pressed("open_minigame"):
			if not minigame: # if haven't created a minigame
				# Creates a minigame and opens it 
				minigame = create_minigame()
				minigame.open()
	
	
func create_minigame() -> Minigame:
	# Spawning minigame scene
	var minigame_instance: Minigame = minigame_scene.instance()
	get_tree().current_scene.add_child(minigame_instance)
	
	# sets position to bottom center of the screen
	var screen_bottom_center := Vector2(Global.player.camera.get_camera_screen_center().x, Global.player.camera.get_camera_screen_center().y + 900)
	minigame_instance.global_position = screen_bottom_center
	minigame_instance.owner_obj = self # sets owner obj to self so it has a reference to this node
	
	return minigame_instance
	
	
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		player_entered = true
		set_process(true)
		
		
func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		player_entered = false
		set_process(false)
