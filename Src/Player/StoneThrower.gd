extends Node

export (String, FILE) var stonePath: String
var stoneScene: Resource

export var stoneSpawnPath: NodePath
onready var stoneSpawn: Position2D = get_node(stoneSpawnPath)


func _ready() -> void:
	stoneScene = load(stonePath)
	set_process(false)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("weapon"):
		var stone = stoneScene.instance()
		stone.global_position = stoneSpawn.global_position
		Global.game_manager.getCurrentLevel().add_child(stone)
		stone.throw(Vector2(500,0))
	
