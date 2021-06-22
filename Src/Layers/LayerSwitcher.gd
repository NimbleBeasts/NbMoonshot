extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(modulate.a < 1):
		modulate.a += delta
	else:
		set_process(false)


func _on_PlayerDetector_body_entered(body):
	if body.is_in_group("Player"):
		modulate.a = 0;
		set_process(false)


func _on_PlayerDetector_body_exited(body):
	if body.is_in_group("Player"):
		set_process(true)

