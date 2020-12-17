extends Node2D

export var linePath: NodePath
export var playerPath: NodePath
export (String, FILE) var objectScenePath: String
export var objectGravity: float = 800
export var startingObjectVelocity: Vector2 = Vector2(500,0)
export var powerToIncrease: int = 50

var objectScene: Resource
var maxPoints: int = 15
var objectVelocity: Vector2

onready var line: Line2D = get_node(linePath)
onready var objectSpawn = $ObjectSpawn
onready var player = get_node(playerPath)


func _ready() -> void:
	objectScene = load(objectScenePath)
	objectVelocity = startingObjectVelocity
	$PowerIncreaseTimer.connect("timeout", self, "increaseThrowPower")
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("weapon"):
		objectVelocity = startingObjectVelocity
		$PowerIncreaseTimer.start()
		Events.emit_signal("block_player_movement")
		updateTrajectory(delta)
	elif Input.is_action_just_released("weapon"):
		line.hide()
		$PowerIncreaseTimer.stop()
		var object = objectScene.instance()
		object.gravity = objectGravity
		object.global_position = objectSpawn.global_position
		Global.game_manager.getCurrentLevel().add_child(object)
		object.throw(objectVelocity)
		Events.emit_signal("unblock_player_movement")


func updateTrajectory(delta: float) -> void:
	line.show()
	line.clear_points()
	var pos = objectSpawn.global_position
	var vel = objectVelocity
	for i in range(maxPoints):
		line.add_point(line.to_local(pos))
		vel.y += objectGravity * delta
		pos += vel * delta
		if pos.y > player.to_global(Vector2(0,0)).y:
			break
			

func increaseThrowPower() -> void:
	objectVelocity.x += powerToIncrease
	updateTrajectory(get_physics_process_delta_time())
