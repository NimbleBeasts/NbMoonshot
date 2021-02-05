extends Node2D

export var extended_allowed_detections: int = 5
export var normal_allowed_detections: int = 3

export (Types.LevelLightning) var level_lightning: int
export (Types.LevelTypes) var level_nation_type: int
export(NodePath) var level_objectives = null
export var playCarCloseSound: bool = true 

var allowed_detections: int
var gainedMoney: int

func can_change_level():
	if level_objectives:
		if level_objectives.has_method("getProgessState"):
			return level_objectives.getProgessState()
		else:
			print("Error: Selected node is not supported")

	# if top condition is false and it reaches here, checks if "HQ_Level"
	if Global.game_manager.getCurrentLevel().name == "HQ_Level":
		return true
	
	# if not hqLevel and getProgressState is false, can't change level
	return false


func _ready():
	var musicEmit 
	if Global.game_manager.getCurrentLevelIndex() != 0:
		musicEmit = level_nation_type
	else:
		musicEmit = "HQ"
	Events.emit_signal("play_music", musicEmit)

	Events.connect("hud_mission_briefing_exited", self, "onHudMissionBriefingExited")
	if Global.game_manager.getCurrentLevelIndex() != 0:
		Events.emit_signal("hud_mission_briefing", Global.game_manager.getCurrentLevelIndex())
		get_tree().paused = true
	else:
		set_process(false)		
	
	if level_objectives:
		level_objectives = get_node(level_objectives)

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
	
	# Update Player Money
	if Global.game_manager.getCurrentLevelIndex() == 0:
		Events.emit_signal("hud_update_money", Global.gameState.money, 0)
	else:
		Events.emit_signal("hud_update_money", 0, 0)
		
		
	Events.emit_signal("hud_light_level", level_lightning)

	if get_node_or_null("NewSkybox"):
		get_node("NewSkybox").setup(level_nation_type)

		
func _process(_delta: float) -> void:
	if can_change_level() == true: # putting this in process T_T
		Events.emit_signal("hud_game_hint", "Mission Complete - Return to HQ")
		set_process(false)

		
# upgrade function
func do_upgrade_stuff() -> void:
	if Types.UpgradeTypes.False_Alarm in Global.gameState.playerUpgrades:
		allowed_detections = extended_allowed_detections
	else:
		allowed_detections = normal_allowed_detections

	Events.emit_signal("allowed_detections_updated", allowed_detections)

	
func onHudMissionBriefingExited() -> void:
	get_tree().paused = false
	if playCarCloseSound:
		Events.emit_signal("play_sound", "car_close")
