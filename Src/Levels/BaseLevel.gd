extends Node2D


export var extended_allowed_detections: int = 5
export var normal_allowed_detections: int = 3

export (Types.LevelLightning) var level_lightning: int
export (Types.LevelTypes) var level_nation_type: int
export (Types.MusicType) var level_music: int = Types.MusicType.DefaultLevelType
export(NodePath) var level_objectives = null
export var playCarCloseSound: bool = true 
export var isSabotage: bool = false
export (Types.Countries) var sabotageCountry

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
	Global.returnedFromSabotageMission = false
	var hud = preload("res://Src/HUD/HUD.tscn").instance()
	self.add_child(hud)
	
	# Level Music 
	if level_music == Types.MusicType.DefaultLevelType:
		if level_nation_type == Types.LevelTypes.USA or level_nation_type == Types.LevelTypes.Switzerland:
			Events.emit_signal("play_music", Types.MusicType.westernMusic)
		else:
			Events.emit_signal("play_music", Types.MusicType.easternMusic)
	else:
		Events.emit_signal("play_music", level_music)

	Events.connect("hud_mission_briefing_exited", self, "onHudMissionBriefingExited")
	Events.connect("hud_mission_progress_exited", self, "onHudMissionProgressExited")

	if Global.game_manager.getCurrentLevelIndex() != 0:
		Events.emit_signal("hud_mission_briefing",level_nation_type)
		get_tree().paused = true
	else:
		if Global.gameState["level"]["lastActiveMission"] >= 0:
			yield(get_tree(), "idle_frame") # if i don't add this line, it crashes when going to hq level
			Events.emit_signal("hud_mission_progress")
			get_tree().paused = true
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
	Events.emit_signal("hud_update_money", Global.gameState.money, 0)
		
		
	Events.emit_signal("hud_light_level", level_lightning)

	if get_node_or_null("NewSkybox"):
		get_node("NewSkybox").setup(level_nation_type)

		
func _process(_delta: float) -> void:
	if can_change_level() == true: # putting this in process T_T
		
		print("haaa")
		Events.emit_signal("hud_game_hint", tr("HUD_MISSION_COMPLETE"))
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

func onHudMissionProgressExited() -> void:
	get_tree().paused = false
