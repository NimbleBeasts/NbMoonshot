extends KinematicBody2D

enum Skins {Scientist1, Scientist2}
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
onready var animPlayer: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	match skin:
		Skins.Scientist1:
			$Flippable/Sprite.texture = preload("res://Assets/Guards/Civ_Scientist.png")
		_:
			$Flippable/Sprite.texture = preload("res://Assets/Guards/Civ_Scientist2.png")
	
	fovArea.connect("body_entered", self, "onFOVBodyEntered")
	if not isHostileArea:
		fovArea.queue_free()
		fovArea = null
		
		
func _physics_process(delta: float) -> void:
	velocity = direction * speed
	if direction.x != 0:
		$Flippable.scale.x = direction.x
		animPlayer.play("walk")
	else:
		animPlayer.play("idle")
	velocity = move_and_slide(velocity)


func setState(newState: int) -> void:
	if state == newState:
		return
	state = newState
	match state:
		Types.CivilianStates.Stunned:
			set_physics_process(false)
			animPlayer.play("tasered")
			if pathLine != null:
				pathLine.stopAllMovement()
			isStunned = true
			if fovArea != null:
				fovArea.set_deferred("monitoring", false)
		Types.CivilianStates.Kneeling:
			set_physics_process(false)
			animPlayer.play("kneeling")
			if pathLine != null:
				pathLine.stopAllMovement()


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
