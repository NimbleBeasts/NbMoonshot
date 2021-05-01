extends Node2D

export var playerPath: NodePath
export var stunRayPath: NodePath
var stunBatteryLevel
onready var player = get_node(playerPath)
onready var stunRay = get_node(stunRayPath)


func _ready() -> void:
	setEnabled(false)
	

func _process(delta: float) -> void:
	if player.blockEntireInput:
		return
	if Input.is_action_just_pressed("weapon"):
		if player.state == Types.PlayerStates.Normal and stunBatteryLevel > 0:
			Events.emit_signal("player_animation_change", "taser")
			get_parent().get_parent().get_node("PlayerSounds/TaserDeploy").play()
			if stunRay.is_colliding():
				var hit = stunRay.get_collider()
				if hit != null and hit.has_method("stun") and not hit.isStunned:
					hit.stun(player.stun_duration)
					stunBatteryLevel -= 1
					Events.emit_signal("player_taser_fired", stunBatteryLevel)
					get_parent().get_parent().get_node("PlayerSounds/TaserHit").play()


func setEnabled(to: bool) -> void:
	set_process(to)
