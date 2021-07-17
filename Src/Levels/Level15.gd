extends "res://Src/Levels/BaseLevel.gd"

var isPowerOn = true
var isHackable = false
var isInstalled = false
var player = null


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(false)


func _process(delta: float) -> void:
	if player and not isHackable and isInstalled:
		#Player got no device
		if Input.is_action_just_pressed("interact") and Global.player.canInteract:
			Events.emit_signal("hud_game_hint", tr("LEVEL15_NO_DEVICE"))

func hackWithDevice():
	if player:
		isHackable = true
		if isPowerOn:
			Events.emit_signal("hud_game_hint", tr("LEVEL15_POWER"))
		else:
			player.itemPickup.removeCurrentItem()
			isInstalled = true
			#print("mission finished")
		isHackable = false

func getProgessState():
	return isInstalled

# Power button
func toggleState():
	isPowerOn = !isPowerOn
	

func _on_ObjectiveArea_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		set_process_input(true)


func _on_ObjectiveArea_body_exited(body):
	if body.is_in_group("Player"):
		player = null
		set_process_input(false)
