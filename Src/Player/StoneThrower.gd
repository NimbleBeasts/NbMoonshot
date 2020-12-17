extends Node

export var stoneSpawnPath: NodePath
export var playerPath: NodePath
export (String, FILE) var stonePath: String
export var stoneGravity: float = 800
export var stoneVelocity: Vector2 = Vector2(500,0)
export var powerToIncrease: int = 50

var stoneScene: Resource
var maxPoints: int = 15

onready var line: Line2D = $Line2D
onready var stoneSpawn = get_node(stoneSpawnPath)
onready var player = get_node(playerPath)


func _ready() -> void:
	$PowerIncreaseTimer.connect("timeout", self, "increaseThrowPower")
	stoneScene = load(stonePath)
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("weapon"):
		$PowerIncreaseTimer.start()
		Events.emit_signal("block_player_movement")
		updateTrajectory(delta)
	elif Input.is_action_just_released("weapon"):
		line.hide()
		$PowerIncreaseTimer.stop()
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
		if pos.y > player.to_global(Vector2(0,0)).y:
			break
			

func increaseThrowPower() -> void:
	stoneVelocity.x += powerToIncrease
	updateTrajectory(get_physics_process_delta_time())
