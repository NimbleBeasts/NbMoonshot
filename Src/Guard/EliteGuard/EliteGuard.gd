extends KinematicBody2D

export var normalSpeed: int = 20
export var chaseSpeed: int = 40

var direction: Vector2
var velocity: Vector2
var speed: int = 20
var foundPlayer: bool
var playerInLOS: bool
var player

onready var losRay: RayCast2D = $Flippable/LOSRay
onready var pathLine: PathLine = $PathLine


func _ready() -> void:
	speed = normalSpeed
	losRay.set_deferred("enabled", false)
	$Flippable/LineOfSight.connect("body_entered", self, "onLOSBodyEntered")
	$Flippable/TaserRange.connect("body_entered", self, "onTaserRangeBodyEntered")


func _physics_process(delta: float) -> void:
	velocity = direction * speed
	velocity = move_and_slide(velocity)
	updateFlip()


func _process(delta: float) -> void:
	if playerInLOS:
		if losRayIsCollidingWithPlayer():
			foundPlayer = true
			pathLine.moveToPoint(player.global_position)
			speed = chaseSpeed
			Events.emit_signal("block_player_movement")
			set_process(false)         

	
func onTaserRangeBodyEntered(body: Node) -> void:
	if body.is_in_group("Player"):
		player = body
		flipTowards(player.global_position)
		Events.emit_signal("play_sound", "taser_hit")
		print("start tasing player animation")
		pathLine.stopAllMovement()
		Events.emit_signal("game_over")


func onLOSBodyEntered(body: Node) -> void:
	if body.is_in_group("Player"):
		losRay.set_deferred("enabled", true)
		playerInLOS = true
		player = body
		$Notifier.popup(Types.NotifierTypes.Exclamation)


func losRayIsCollidingWithPlayer() -> bool:
	return losRay.is_colliding() and losRay.get_collider().is_in_group("Player")
	

func updateFlip() -> void:
	if direction.x != 0:
		$Flippable.scale.x = direction.normalized().x


func flipTowards(towards: Vector2) -> void:
	if towards.x > global_position.x:
		$Flippable.scale.x = 1
	elif towards.x < global_position.x:
		$Flippable.scale.x = -1
