extends Area2D

signal minigame_created

export (Types.Minigames) var type

var player_entered: bool = false
var minigame
var minigame_scene

onready var current_scene: Node = get_tree().current_scene
onready var tween: Tween = $MinigameTween


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
				open_created_minigame(minigame)
		
		if Input.is_action_just_pressed("open_minigame"):
			open_created_minigame(minigame)
		
		if Input.is_action_just_pressed("close_minigame"):
			close_created_minigame(minigame)			


func create_minigame() -> Node2D:
	# Spawning minigame scene
	var minigame_instance = minigame_scene.instance()
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
	# Emits signal
	Events.emit_signal("minigame_entered", type)


func close_created_minigame(minigame_instance: Node) -> void:
	var screen_bottom_center := Vector2(get_viewport_rect().size.x / 2,  get_viewport_rect().size.y + 500) #adds a bit for extra measure
	# tweening position 
	tween.interpolate_property(minigame_instance, "global_position", 
			minigame_instance.global_position, screen_bottom_center, 0.2, Tween.TRANS_LINEAR)
	tween.start()
	# Emits signal
	Events.emit_signal("minigame_exited", Types.MinigameResults.Succeeded)
	
	
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		player_entered = true
		set_process(true)
		
		
func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		player_entered = false
		set_process(false)
