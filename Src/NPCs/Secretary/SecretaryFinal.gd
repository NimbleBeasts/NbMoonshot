extends NewNPC


func _ready() -> void: 
	$AnimationPlayer.play("idle")
	setInteractedCounter(0)
	connect("npc_dialogue_finished", self, "dialogue_finished")
	
	
func dialogue_finished():
	$AnimationPlayer.play("walk")
