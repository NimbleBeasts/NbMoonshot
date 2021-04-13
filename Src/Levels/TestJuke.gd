tool
extends Sprite


export(bool) var emitting = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	$Label.set_text(str(global_position))
	if emitting:
		Events.emit_signal("play_sound", "test", 1.0, Global.calcAudioPosition(global_position))
