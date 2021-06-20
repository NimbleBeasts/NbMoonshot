extends RayCast2D

signal apply_gravity()
signal stop_applying_gravity()


func _ready():
	setEnabled(true)


func setEnabled(state):
	self.enabled = state

func _physics_process(delta):
	if self.enabled:
		if self.is_colliding():
			get_parent().get_node("Label2").set_text(str(get_collision_point()))
			emit_signal("stop_applying_gravity")
			
		else:
			emit_signal("apply_gravity")
			get_parent().get_node("Label2").set_text("")
