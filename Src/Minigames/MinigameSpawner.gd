class_name MinigameSpawner
extends Area2D

signal minigame_succeeded

var player_entered: bool = false
var minigame: Minigame
var minigame_scene: PackedScene
var can_make_minigame: bool = true
var minigame_succeeded: bool = false

onready var game_manager := get_node("/root/GameManager")


func _ready() -> void:
	#warning-ignore:return_value_discarded
	connect("area_entered", self, "_on_area_entered")
	#warning-ignore:return_value_discarded
	connect("area_exited", self, "_on_area_exited")

func _base_process(_delta: float) -> void:
	if player_entered and can_make_minigame: # if player is near
		if Input.is_action_just_pressed("open_minigame"):
			if not minigame: # if haven't created a minigame
				# Creates a minigame and opens it 
				minigame = create_minigame()
				#warning-ignore:return_value_discarded
				minigame.connect("result_changed", self, "_on_minigame_result_changed")
				minigame.open()
				print("I am WTFfrom parent")
	
	
func _process(_delta: float) -> void:
	_base_process(_delta)
	
	
func create_minigame() -> Minigame:
	var minigame_instance: Minigame = minigame_scene.instance()
	
	game_manager.levelNode.get_node("MinigameHolder").add_child(minigame_instance)
	minigame_instance.owner_obj = self # sets owner obj to self so it has a reference to this node
	
	
	# sets position to bottom center of the screen
	var screen_bottom_center = Global.screen_bottom_center
	minigame_instance.global_position = screen_bottom_center
	
	return minigame_instance


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		player_entered = true
		set_process(true)
		
		
func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		player_entered = false
		set_process(false)


func _on_minigame_result_changed(result: int) -> void:
	if result == Types.MinigameResults.Succeeded:
		can_make_minigame = false
		minigame_succeeded = true
		emit_signal("minigame_succeeded")

		
func getProgessState() -> bool:
	return minigame_succeeded

