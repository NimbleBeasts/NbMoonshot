extends Node2D


func _ready():
	# Set all decoration sprites to correct light level 
	var decoHolder = get_node("LevelObjects/Decorations")
	if decoHolder:
		var decorationSprites = decoHolder.get_children()
		for node in decorationSprites:
			node.light_mask = 3
			
	var wallSpriteHolder = get_node("SpriteWalls")
	if wallSpriteHolder:
		var wallSprites = wallSpriteHolder.get_children()
		for node in wallSprites:
			node.light_mask = 3

