extends Node2D

export var objectSpawnPath: NodePath
export var playerPath: NodePath
export (String, FILE) var objectScenePath: String
export var objectGravity: float = 800
export var startingObjectVelocity: Vector2 = Vector2(150,0)
export var powerToIncrease: int = 50
export var infiniteAmmo: bool = true
export var currentAmmo: int = 3

var objectScene: Resource
var maxPoints: int = 15
var objectVelocity: Vector2
var lastPlayerDir: Vector2 = Vector2(1, 0) # because player faces right at beginning
var maxPower: int = 300
var inShootMode: bool = false

onready var objectStopPosition: Vector2 = Vector2(0,-3)
onready var line: Line2D = $Line2D
onready var objectSpawn = get_node(objectSpawnPath)
onready var player = get_node(playerPath)
# onready var testBody: KinematicBody2D = $TestBody


func _ready() -> void:
	objectScene = load(objectScenePath)
	objectVelocity = startingObjectVelocity
	$PowerIncreaseTimer.connect("timeout", self, "increaseThrowPower")
	Events.connect("game_over", self, "onGameOver")
	setEnabled(false)


func _process(delta: float) -> void:
	if player.blockEntireInput:
		return
	if player.direction.x != 0:
		objectVelocity = startingObjectVelocity * player.direction
		lastPlayerDir = player.direction


func _input(event: InputEvent) -> void:
	if player.blockEntireInput:
		return
	if not event is InputEventKey:
		return
	if Input.is_action_just_pressed("weapon") and (currentAmmo > 0 or infiniteAmmo):
		objectVelocity = startingObjectVelocity * lastPlayerDir
		$PowerIncreaseTimer.start()
		Events.emit_signal("block_player_movement")
		Events.emit_signal("change_player_animation", "throw_load")
		updateTrajectory(get_physics_process_delta_time())
		currentAmmo = int(max(currentAmmo - 1, 0))
		inShootMode = true
	elif Input.is_action_just_released("weapon") and inShootMode:
		line.hide()
		$Mark.hide()
		$PowerIncreaseTimer.stop()
		var object = objectScene.instance()
		object.gravity = objectGravity
		object.global_position = objectSpawn.global_position
		object.stopPosition = player.to_global(objectStopPosition)
		Global.game_manager.getCurrentLevel().add_child(object)
		# testBody.get_node("CollisionShape2D").shape = object.collisionShape.shape
		object.throw(objectVelocity)
		Events.emit_signal("change_player_animation", "throw")
		inShootMode = false


func updateTrajectory(delta: float) -> void:
	line.show()
	line.clear_points()
	var pos = objectSpawn.global_position
	# testBody.global_position = pos
	var vel = objectVelocity
	for _i in range(maxPoints):
		line.add_point(line.to_local(pos))
		vel.y += objectGravity * delta
		pos += vel * delta
		# var collision = testBody.move_and_collide(vel * delta, true, true, true)
		# if collision:
		# 	vel /= 5
		# 	vel = vel.bounce(collision.normal)
		if pos.y > player.to_global(objectStopPosition).y:
			break
	
	var lastPoint = line.get_point_count() - 1
	var markPos = line.get_point_position(lastPoint)
	line.remove_point(lastPoint)
	
	$Mark.position = markPos
	$Mark.show()


func increaseThrowPower() -> void:
	if abs(objectVelocity.x) + powerToIncrease <= maxPower:
		objectVelocity.x += (powerToIncrease * lastPlayerDir.x)
	else:
		$PowerIncreaseTimer.stop()
	updateTrajectory(get_physics_process_delta_time())


func setEnabled(to: bool) -> void:
	set_process_input(to)


func onGameOver() -> void:
	setEnabled(false)
