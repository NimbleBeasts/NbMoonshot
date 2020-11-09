extends Node2D

export var allowed_detections: int = 3

func _process(_delta):
	var mouse = get_global_mouse_position() 
	$HUD/Label.set_text("Mouse Pos: " + str(mouse))


