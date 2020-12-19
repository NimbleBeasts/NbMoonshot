tool
extends HideOutBase

enum ClosetTypes {Wooden, Metal}

var type = ClosetTypes.Wooden

func _ready():
	if type == ClosetTypes.Wooden:
		$Sprite.texture = preload("res://Assets/HideOuts/WoodCloset.png")
		$Bg.texture = preload("res://Assets/HideOuts/WoodClosetBg.png")
	else:
		$Sprite.texture = preload("res://Assets/HideOuts/MetalCloset.png")
		$Bg.texture = preload("res://Assets/HideOuts/MetalClosetBg.png")
	
	$Sprite.frame = 0

