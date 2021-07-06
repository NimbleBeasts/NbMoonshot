extends Area2D
class_name Pickupable

export var pickupName: String
export var showGameHints: bool = true
var isPickedUp: bool = false
#warning-ignore:unused_class_variable
var mainNode = self # this is needed for the pressure button, don't remove this
var applyGravity: bool = false
var grav: int = 8000

onready var sprite: Sprite = $Sprite # also for pressure button


func _ready() -> void:
	# for pressure
	set_collision_layer_bit(9, true)
	$GroundCast.connect("apply_gravity", self, "setApplyGravity", [true])
	$GroundCast.connect("stop_applying_gravity", self, "setApplyGravity", [false])
	$Sprite.set_material($Sprite.get_material().duplicate())

	
func _physics_process(delta: float) -> void:
	var velocity = Vector2(0,0)
	if applyGravity:
		velocity.y += grav * delta
		
	global_position += velocity * delta
	
	if $Label:
		$Label.set_text(str(global_position))


func pickup() -> void:
	setPickedUp(true)
	$Sprite.material.set_shader_param("active", false)
	if showGameHints:
		Events.emit_signal("hud_game_hint", tr("PICKUP_UP") + " " + tr(pickupName))
	
func drop() -> void:
	setPickedUp(false)
	$Sprite.material.set_shader_param("active", true)
	if showGameHints:
		Events.emit_signal("hud_game_hint", tr("PICKUP_DOWN")  + " " + tr(pickupName))


func setPickedUp(state):
	$GroundCast.setEnabled(!state) #Disable if picked up
	isPickedUp = state

func getProgessState() -> bool:
	return isPickedUp

	
func setApplyGravity(to: bool):
	applyGravity = to

	
func _on_FCU_body_entered(body):
	if body.is_in_group("Player"):
		$Sprite.material.set_shader_param("active", true)


func _on_FCU_body_exited(body):
	if body.is_in_group("Player"):
		$Sprite.material.set_shader_param("active", false)

