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
var applyGravity: bool = false
var gravity: int = 800
var physicsProcessAnims: bool = true
var isSleeping: bool = false


onready var pathLine: PathLine = get_node_or_null("PathLine")
onready var fovArea: Area2D = $Flippable/FOV
onready var animPlayer: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	$AnimationPlayer.connect("animation_finished", self, "onAnimationFinished")
	$GroundDetection.connect("apply_gravity", self, "setApplyGravity", ["dummy", true])
	$GroundDetection.connect("body_entered", self, "setApplyGravity", [false])
	for child in self.get_children():
		if child is Line2D:
			# Path detected
			pathLine = child
			
			if not child.has_method("moveToNextPoint"):
				print("Civilian: " + str(self) + " - Path node used. Was this intended?")

	
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
	if applyGravity:
		velocity.y += gravity * delta
		direction.x = 0
		velocity.x = 0
	else:
		velocity = direction * speed
	velocity = move_and_slide(velocity)
	
	if not physicsProcessAnims:
		return	
	if direction.x != 0:
		$Flippable.scale.x = direction.x
		animPlayer.play("walk")
	else:
		animPlayer.play("idle")


func setState(newState: int) -> void:
	if state == newState:
		return
	state = newState
	match state:
		Types.CivilianStates.Stunned:
#			set_physics_process(false)
			physicsProcessAnims = false
			animPlayer.play("tasered")
			if pathLine != null:
				pathLine.stopAllMovement()
			isStunned = true
			if fovArea != null:
				fovArea.set_deferred("monitoring", false)
		Types.CivilianStates.Kneeling:
#			set_physics_process(false)
			physicsProcessAnims = false
			animPlayer.play("kneeling")
			if pathLine != null:
				pathLine.stopAllMovement()


func stun(_d) -> void:
	setState(Types.CivilianStates.Stunned)

	
func onFOVBodyEntered(body: Node) -> void:
	if body.is_in_group("Player"):
		setState(Types.CivilianStates.Kneeling)


func flip(to):
	$Flippable.scale.x = to

# for the pickup script, since it's for both guards and civilians and they don't have the same variables,
# i used functions that returned correct value instead
# this causes 1 liner functions but oh well
func canDrag() -> bool:
	return state == Types.CivilianStates.Stunned and isSleeping

func isBeingDragged() -> bool:
	return state == Types.CivilianStates.BeingDragged

func drag() -> void:
	# Put in foreground
	#TODO: Maybe we change the index when stunned so we have no overlap change
	$Flippable/Sprite.z_index = 51
	setState(Types.CivilianStates.BeingDragged)
	$AnimationPlayer.play("carry")

func stopBeingDragged() -> void:
	# Put background again
	$Flippable/Sprite.z_index = 0
	state = Types.CivilianStates.Stunned
	$AnimationPlayer.play("drop")

# level objective support
func getProgessState() -> bool:
	return isBeingDragged()

func setApplyGravity(_dummyargument, to: bool):
	applyGravity = to

func onAnimationFinished(animName: String) -> void:
	if animName == "tasered":
		isSleeping = true
