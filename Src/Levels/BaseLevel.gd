extends Node2D

export var extended_allowed_detections: int = 5
export var normal_allowed_detections: int = 3

var allowed_detections: int
export (Types.LevelTypes) var level_type: int

var can_change_level: bool = false


func _ready():
	add_to_group("Upgradable")
	do_upgrade_stuff()
	# Set all decoration sprites to correct light level 
	var decoHolder = get_node_or_null("LevelObjects/Decorations")
	if decoHolder:
		var decorationSprites = decoHolder.get_children()
		for node in decorationSprites:
			node.light_mask = 3
			
	var wallSpriteHolder = get_node_or_null("SpriteWalls")
	if wallSpriteHolder:
		var wallSprites = wallSpriteHolder.get_children()
		for node in wallSprites:
			node.light_mask = 3

# upgrade function
func do_upgrade_stuff() -> void:
	if Types.UpgradeTypes.False_Alarm in Global.gameState.playerUpgrades:
		allowed_detections = extended_allowed_detections
	else:
		allowed_detections = normal_allowed_detections

	Events.emit_signal("allowed_detections_updated", allowed_detections)