extends Area2D

export (Types.Minigames) var type

var player_entered: bool = false
var minigame: Minigame
var minigame_scene

onready var current_scene: Node = get_tree().current_scene
onready var tween: Tween = $MinigameTween
onready var game_manager := get_node("/root/GameManager")


func _ready() -> void:
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")
	# sets minigame scene checking type
	match type:
		Types.Minigames.Test:
			minigame_scene = load("res://Src/Minigames/TestMinigame.tscn")
	

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
	game_manager.levelNode.add_child(minigame_instance)
	
	# sets position to bottom center of the screen
	minigame_instance.global_position = Vector2(get_viewport_rect().size.x / 2,  get_viewport_rect().size.y)
	minigame_instance.owner_door = self # sets owner door to self
	
	return minigame_instance
	
	
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		player_entered = true
		set_process(true)
		
		
func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		player_entered = false
		set_process(false)
