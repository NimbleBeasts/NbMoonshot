extends KinematicBody2D

enum Skins {Test}
export (Skins) var skin: int
export var isHostileArea: bool 
export var speed: int = 35

var direction: Vector2
var velocity: Vector2
var isStunned: bool = false
var beingDragged: bool
var state: int

onready var pathLine: PathLine = get_node_or_null("PathLine")
onready var fovArea: Area2D = $Flippable/FOV

func _ready() -> void:
	fovArea.connect("body_entered", self, "onFOVBodyEntered")
	if not isHostileArea:
		fovArea.queue_free()

	
func _physics_process(delta: float) -> void:
	velocity = direction * speed
	updateFlip()
	velocity = move_and_slide(velocity)

	
func setState(newState: int) -> void:
	if state == newState:
		return
	state = newState
	match state:
		Types.CivilianStates.Stunned:
			if pathLine != null:
				pathLine.stopAllMovement()
			isStunned = true
			fovArea.set_deferred("monitoring", false)
		Types.CivilianStates.Kneeling:
			print("kneeling state")
			if pathLine != null:
				pathLine.stopAllMovement()


func updateFlip() -> void:
	if direction.x != 0:
		$Flippable.scale.x = direction.x


func stun(_d) -> void:
	setState(Types.CivilianStates.Stunned)

	
func onFOVBodyEntered(body: Node) -> void:
	if body.is_in_group("Player"):
		setState(Types.CivilianStates.Kneeling)


# for the pickup script, since it's for both guards and civilians and they don't have the same variables,
# i used functions that returned correct value instead
# this causes 1 liner functions but oh well
func canDrag() -> bool:
	return state == Types.CivilianStates.Stunned

func isBeingDragged() -> bool:
	return state == Types.CivilianStates.BeingDragged

func drag() -> void:
	setState(Types.CivilianStates.BeingDragged)
	
func stopBeingDragged() -> void:
	state = Types.CivilianStates.Stunned

# level objective support
func getProgessState() -> bool:
	return isBeingDragged()
