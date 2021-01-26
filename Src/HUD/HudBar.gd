extends NinePatchRect


var previousSize = Vector2(0, 0)


# Called when the node enters the scene tree for the first time.
func _ready():
	previousSize = $vbox.rect_size
	
	print("original size")
	print($vbox.rect_size)
	$vbox/LLives.set_text("999999999999999999")



func _on_vbox_resized():
	if $vbox.rect_size != previousSize: # Discard initial change
		previousSize = $vbox.rect_size
		print("resized changed")
		print($vbox.rect_size)
		
		var offset = int($vbox.rect_size.x / 2) + 2
#		self.margin_left = -offset
#		self.margin_right = offset
	
