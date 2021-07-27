extends Area2D

# All this script does is if player is close enough to be in area, and player clicks interact in input map
# changes level to exported variable

var player_entered: bool = false
export var level_index: int = 0
export var next_level: int = 0
export(Types.Direction) var sprite_face_direction = Types.Direction.Left


func _ready() -> void:
	Global.currentLevel = next_level - 1


	set_process_unhandled_input(false)
	var levelIndex: int = Global.game_manager.getCurrentLevelIndex()
	if levelIndex != 0:
		Global.gameState["level"]["hasActiveMission"] = true
		Global.gameState["level"]["lastActiveMission"] = levelIndex
	#warning-ignore-all:return_value_discarded
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")
	
	$Sprite.frame = 0
	
	if sprite_face_direction == Types.Direction.Left:
		$Sprite.scale.x = -1
	
	Console.remove_command('level_next')
	Console.add_command('level_next', self, 'cheat_level_next')\
		.set_description('Go to next level')\
		.register()

func cheat_level_next():
	_on_AnimationPlayer_animation_finished("")
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if Global.game_manager.getCurrentLevel().can_change_level():
			if Global.gameState["level"]["hasActiveMission"] and Global.gameState["level"]["lastActiveMission"] != 0:
				$AnimationPlayer.play("open")
				$CarOpen.play()
				Events.emit_signal("player_block_movement")
				get_tree().set_input_as_handled()

			
func _on_body_entered(body: Node) -> void:
	if body is Player:
		player_entered = true
		set_process_unhandled_input(true)


func _on_body_exited(body: Node) -> void:
	if body is Player:
		player_entered = false
		set_process_unhandled_input(false)

func manualLevelFinish():
	_on_AnimationPlayer_animation_finished("")

func _on_AnimationPlayer_animation_finished(_anim_name):
	if Global.game_manager.getCurrentLevel().name == "HQ_Level": # this condition is true on hq_level
		Events.emit_signal("hud_level_transition", -1)
		Global.game_manager.loadNextQuest()
	else: 
		# this is going to hq level
		
		# Achievment
		if Global.allowed_detections == Global.lives:
			SteamWorks.setAchievement("STEAM_ACH_8")
		
		Events.emit_signal("hud_level_transition", level_index)
		Global.addMoney(Global.game_manager.getCurrentLevel().gainedMoney)
		# if Global.game_manager.getCurrentLevel().isSabotage:
		# 	Global.returnedFromSabotageMission = true
		# 	Global.gameState.level.id = Global.game_manager.getCurrentLevelIndex()
			#var countryString = Types.Countries.keys()[Global.game_manager.getCurrentLevel().sabotageCountry]
			#Global.gameState["sabotageCounters"][countryString] += 1
			#print("Sabotage progress of %s set to %s " % [countryString, Global.gameState["sabotageCounters"][countryString]])
		#else:
		Global.gameState.level.id = next_level

		Global.addMoney(100) # successful level change
		Global.game_manager.unloadLevel()
		Global.game_manager.loadLevel(level_index)

		# game state stuff for saving
		Global.gameState["level"]["hasActiveMission"] = false
		Global.gameState["level"]["lastActiveMission"] = -1
