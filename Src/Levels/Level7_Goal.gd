extends Area2D

var playerInRange = null
var isUsed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func getProgessState():
	return isUsed
	
func _process(_delta):
	if playerInRange and playerInRange.state != Types.PlayerStates.DraggingGuard:
		if Input.is_action_just_pressed("open_minigame"):
			isUsed = true
			Events.emit_signal("level_hint", tr("HUD_MISSION_COMPLETE"))
			Events.emit_signal("play_sound", "chest_bounty")

func _on_Goal_body_entered(body):
	if body.is_in_group("Player"):
		playerInRange = body
		set_process(true)


func _on_Goal_body_exited(body):
	if body.is_in_group("Player"):
		playerInRange = null
		set_process(false)
