extends Area2D

signal minigame_created

export (String, FILE) var minigame_scene_path: String

var player_entered: bool = false
var minigame: Node

onready var minigame_scene: PackedScene = load(minigame_scene_path)
onready var current_scene: Node = get_tree().current_scene
onready var tween: Tween = $MinigameTween


func _ready() -> void:
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")
	

func _process(delta: float) -> void:
	if player_entered: # if player is near
		if Input.is_action_just_pressed("open_minigame"):
			if not minigame: # if haven't created a minigame
				# Creates a minigame and opens it 
				minigame = create_minigame()
				open_created_minigame(minigame)
			else: # if already has a minigame
				open_created_minigame(minigame)
				
	if minigame:
		if Input.is_action_just_pressed("close_minigame"):
			close_created_minigame(minigame)


func create_minigame() -> Node:
	# Spawning minigame scene
	var minigame_instance: Node = minigame_scene.instance()
	current_scene.add_child(minigame_instance)
	
	# sets position to bottom center of the screen
	minigame_instance.global_position = Vector2(get_viewport_rect().size.x / 2,  get_viewport_rect().size.y)
	
	return minigame_instance
	

# Basically open and close minigame are just tweening the minigame position 
func open_created_minigame(minigame_instance: Node) -> void:
	var screen_center: Vector2 = get_viewport_rect().size / 2
	# tweening position 
	tween.interpolate_property(minigame_instance, "global_position", 
			minigame_instance.global_position, screen_center, 0.2, Tween.TRANS_LINEAR)
	tween.start()
	# player cannot move now unless they close
	Global.player.can_move = false

func close_created_minigame(minigame_instance: Node) -> void:
	var screen_bottom_center := Vector2(get_viewport_rect().size.x / 2,  get_viewport_rect().size.y + 500) #adds a bit for extra measure
	# tweening position 
	tween.interpolate_property(minigame_instance, "global_position", 
			minigame_instance.global_position, screen_bottom_center, 0.2, Tween.TRANS_LINEAR)
	tween.start()
	# player can move now
	Global.player.can_move = true
	
	
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		player_entered = true
		set_process(true)
		
		
func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		player_entered = false
		set_process(false)
