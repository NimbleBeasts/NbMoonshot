class_name MinigameSpawner
extends Area2D

export (Types.Minigames) var type
export (int) var lock_code: int

var player_entered: bool = false
var minigame: Minigame
var can_make_minigame: bool = true

onready var current_scene: Node = get_tree().current_scene
onready var game_manager := get_node("/root/GameManager")


func _ready() -> void:
	#warning-ignore:return_value_discarded
	connect("area_entered", self, "_on_area_entered")
	#warning-ignore:return_value_discarded
	connect("area_exited", self, "_on_area_exited")
	

func _process(_delta: float) -> void:
	if player_entered and can_make_minigame: # if player is near
		if Input.is_action_just_pressed("open_minigame"):
			if not minigame: # if haven't created a minigame
				# Creates a minigame and opens it 
				minigame = create_minigame()
				minigame.open()
	
	
func create_minigame() -> Minigame:
	var minigame_instance: Minigame = get_minigame_instance_by_type()
	
	game_manager.levelNode.get_node("HUD").add_child(minigame_instance)
	minigame_instance.owner_obj = self # sets owner obj to self so it has a reference to this node
	
	
	# sets position to bottom center of the screen
	var screen_bottom_center := Vector2(Global.player.camera.get_camera_screen_center().x, Global.player.camera.get_camera_screen_center().y + 900)
	minigame_instance.global_position = screen_bottom_center
	
	return minigame_instance

# this function checks type and returns proper instance and also sets variables to exported variables here
func get_minigame_instance_by_type() -> Minigame:
	var result: Minigame
	match type:
		Types.Minigames.Test:
			result = load("res://Src/Minigames/TestMinigame.tscn").instance()
		Types.Minigames.Keypad:
			result = load("res://Src/Minigames/KeypadMinigame/KeypadMinigame.tscn").instance()
			result.goal = lock_code
		Types.Minigames.WireCut:
			result = load("res://Src/Minigames/WireCutMinigame/WireCutMinigame.tscn").instance()
	return result
	
	
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		player_entered = true
		set_process(true)
		
		
func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		player_entered = false
		set_process(false)

	
