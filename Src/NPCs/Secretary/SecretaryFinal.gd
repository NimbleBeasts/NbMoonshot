extends NewNPC


func _ready() -> void: 
	$AnimationPlayer.play("idle")
	setInteractedCounter(0)
	connect("npc_dialogue_finished", self, "dialogue_finished")
	
	
func dialogue_finished():
	Events.emit_signal("hud_dialogue_hide")
	set_process_input(false)
	player = null
	$AnimationPlayer.play("walk")
