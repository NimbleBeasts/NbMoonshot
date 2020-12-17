extends Node

export var stoneSpawnPath: NodePath
export (String, FILE) var stonePath: String
export var stoneGravity: float = 800
export var stoneVelocity: Vector2 = Vector2(500,0)

var stoneScene: Resource
var maxPoints: int = 15

onready var line: Line2D = $Line2D
onready var stoneSpawn = get_node(stoneSpawnPath)


func _ready() -> void:
	stoneScene = load(stonePath)
	set_process(false)


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("weapon"):
		Events.emit_signal("block_player_movement")
		updateTrajectory(delta)
	elif Input.is_action_just_released("weapon"):
		line.hide()
		var stone = stoneScene.instance()
		stone.gravity = stoneGravity
		stone.global_position = stoneSpawn.global_position
		Global.game_manager.getCurrentLevel().add_child(stone)
		stone.throw(stoneVelocity)
		Events.emit_signal("unblock_player_movement")


func updateTrajectory(delta: float) -> void:
	line.show()
	line.clear_points()
	var pos = stoneSpawn.global_position
	var vel = stoneVelocity
	for i in range(maxPoints):
		line.add_point(pos)
		vel.y += stoneGravity * delta
		pos += vel * delta
		
			
	
