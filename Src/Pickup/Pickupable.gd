extends Area2D
class_name Pickupable

export var pickupName: String
export var showGameHints: bool = true
var isPickedUp: bool = false
#warning-ignore:unused_class_variable
var mainNode = self # this is needed for the pressure button, don't remove this
var grav: int = 8000
var target: Vector2 = Vector2(0, 0)



#onready var sprite: Sprite = $Sprite # also for pressure button


func _ready() -> void:
	# for pressure
	set_collision_layer_bit(9, true)
	$GroundCast.connect("ground_detected", self, "ground_detected")
	$Sprite.set_material($Sprite.get_material().duplicate())
	
	$GroundCast.setEnabled(true)

	
func _physics_process(delta: float) -> void:
	var velocity = Vector2(0,0)
	if target != global_position:
		velocity.y += grav * delta
		
		global_position += velocity * delta

		if target != Vector2(0, 0):
			# Ground is set
			# This is a backup solution to avoid falling thru floors
			if global_position.y >= target.y:
				global_position.y = target.y
				target = global_position
				$GroundCast.setEnabled(false)
	
	if $Label:
		$Label.set_text(str(global_position))
	if $Label2:
		$Label2.set_text(str(target))




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


func ground_detected(coords):
	#print("Ground found: " + str(coords))
	target = coords

func _on_FCU_body_entered(body):
	if body.is_in_group("Player"):
		$Sprite.material.set_shader_param("active", true)


func _on_FCU_body_exited(body):
	if body.is_in_group("Player"):
		$Sprite.material.set_shader_param("active", false)

