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


func _physics_process(delta: float) -> void:
	velocity = direction * speed
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
			

func stun(_d) -> void:
	setState(Types.CivilianStates.Stunned)
	
func canDrag() -> bool:
	return state == Types.CivilianStates.Stunned

func isBeingDragged() -> bool:
	return state == Types.CivilianStates.BeingDragged

func drag() -> void:
	setState(Types.CivilianStates.BeingDragged)
	
func stopBeingDragged() -> void:
	state = Types.CivilianStates.Stunned

func getProgessState() -> bool:
	return isBeingDragged()
