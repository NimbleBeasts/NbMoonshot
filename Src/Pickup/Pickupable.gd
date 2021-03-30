extends Area2D
class_name Pickupable

export var pickupName: String
export var showGameHints: bool = true
var isPickedUp: bool = false
var mainNode = self # this is needed for the pressure button, don't remove this
var applyGravity: bool = false
var grav: int = 8000

onready var sprite: Sprite = $Sprite # also for pressure button


func _ready() -> void:
	# for pressure
	set_collision_layer_bit(9, true)
	$GroundDetection.connect("apply_gravity", self, "setApplyGravity", [true])
	$GroundDetection.connect("stop_applying_gravity", self, "setApplyGravity", [false])
	$Sprite.set_material($Sprite.get_material().duplicate())

	
func _physics_process(delta: float) -> void:
	var velocity = Vector2(0,0)
	if applyGravity:
		velocity.y += grav * delta
		
	global_position += velocity * delta
	
func pickup() -> void:
	isPickedUp = true
	$Sprite.material.set_shader_param("active", false)
	if showGameHints:
		Events.emit_signal("hud_game_hint", "Picked up " + str(pickupName))
	
func drop() -> void:
	isPickedUp = false
	$Sprite.material.set_shader_param("active", true)
	if showGameHints:
		Events.emit_signal("hud_game_hint", "Dropped " + str(pickupName))

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
