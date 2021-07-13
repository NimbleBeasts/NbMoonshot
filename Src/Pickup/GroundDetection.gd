extends RayCast2D

signal ground_detected(target)


func _ready():
	setEnabled(true)


func setEnabled(state):
	self.enabled = state
	

func _physics_process(delta):
	if self.enabled:
		if self.is_colliding():
			#print("Ground detected: " + str(get_collision_point()))
			emit_signal("ground_detected", get_collision_point())
			self.enabled = false


