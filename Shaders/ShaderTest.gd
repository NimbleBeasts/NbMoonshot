tool
extends Node2D


func calc_aspect_ratio():
	$Sprite.material.set('shader_param/aspect_ratio', $Sprite.scale.y / $Sprite.scale.x)
	#print("ratio: " + str($Sprite.scale.y / $Sprite.scale.x))
