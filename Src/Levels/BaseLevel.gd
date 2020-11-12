extends Node2D

export var allowed_detections: int = 3
export (Types.LevelTypes) var level_type: int

func _ready():
	# Set all decoration sprites to correct light level 
	var decoHolder = get_node_or_null("LevelObjects/Decorations")
	if decoHolder:
		var decorationSprites = decoHolder.get_children()
		for node in decorationSprites:
			node.light_mask = 3
			
	var wallSpriteHolder = get_node_or_null	("SpriteWalls")
	if wallSpriteHolder:
		var wallSprites = wallSpriteHolder.get_children()
		for node in wallSprites:
			node.light_mask = 3

