tool
extends "res://Src/HideOuts/HideOutBase.gd"


enum Types {Wooden, Metal}


var type = Types.Wooden


func _ready():
	if type == Types.Wooden:
		$Sprite.texture = preload("res://Assets/HideOuts/WoodCloset.png")
	else:
		$Sprite.texture = preload("res://Assets/HideOuts/MetalCloset.png")

