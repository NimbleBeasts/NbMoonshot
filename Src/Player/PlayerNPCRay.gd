extends RayCast2D


func _physics_process(delta: float) -> void:
	if is_colliding():
		var npc = get_collider() as NPC
		if npc and Input.is_action_just_pressed("interact"):
			Events.emit_signal("interacted_with_npc", npc)
			npc.emit_signal("player_interacted")
