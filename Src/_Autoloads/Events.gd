extends Node

#warning-ignore-all:unused_signal

const DEBUG_OUTPUT_ON_SIGNAL_CONNECT = false

###############################################################################
# Global Signal List
###############################################################################

#####################################################################################
# Level Management
#####################################################################################
## Starts a new Game
signal new_game(startLevel)

#####################################################################################
# Detection
#####################################################################################
## Emitted when player makes noises - Audio Levels, audio_pos is the position where the audio notification was emitted for nearby guards
signal audio_level_changed(newLevel, audio_pos, emitter) #Types.AudioLevels
## Emitted when players visibility changes
signal visible_level_changed(newLevel)
## Emitted when the player is detected
signal player_detected(detection_type) # Types.DetectionLevels

#####################################################################################
# Minigames
#####################################################################################
## Emitted when a minigame is started
signal minigame_entered(minigame_type) #Types.Minigames
## Emitted when a minigame is closed
signal minigame_exited(result) #Types.Minigames
## Emitted when menu is called or player is detected
signal minigame_forcefully_close()
## Emitted by minigame to open/close door
signal minigame_door_change_status(door_name, lock_type, exec_anim) #exec anim is bool for switch state anim

#####################################################################################
# HUD
#####################################################################################
## Emitted to show note
signal hud_note_show(node, type, text)
## Emitted on closing note
signal hud_note_exited(node)
## Emitted to show dialogue
signal hud_dialog_show(name, nameColor, text, isMultipage, npcPotrait)
## Emitted on closing dialogue
signal hud_dialog_exited()
## Emitted to show upgrade window
signal hud_upgrade_window_show()
## Emitted on closing upgrade window
signal hud_upgrade_window_exited() #TODO: no listener
## Emitted to show save window
signal hud_save_window_show()
## Emitted on closing save window
signal hud_save_window_exited()
## Emitted to show mission briefing window
signal hud_mission_briefing(level)
## Emitted on closing mission briefing window
signal hud_mission_briefing_exited()
## Emitted to show game over screen
signal hud_game_over()
## Emitted on closing game over screen
signal hud_game_over_exited() #TODO: no listener

## Emitted on money update
signal hud_update_money(total, amount)
## Emitted to show game hint
signal hud_game_hint(text)
## Emitted to show photo flash anim
signal hud_photo_flash()




#####################################################################################
#TODO: Emitted but never listend to list - can be removed?:
signal hud_notification_show(type, node) #Types.HudNotificationType, self reference
signal hud_notification_exited()
signal hud_level_transition(level) #Mission briefing or -1 for returning to HQ
signal hud_level_transition_exited()
#####################################################################################

# dialog branching
signal dialogue_hide()
signal update_dialog_option(type, text)
signal no_branch_option_pressed()
signal dialog_typing_changed(value)
signal skip_dialog()
signal dialog_button_pressed(buttonType)

signal update_branch_button_state(enabled)
signal update_no_branch_button_state(enabled)

signal change_dialog_button_state(buttonType, enabled)

signal save_game()





# Taser
signal taser_fired(charges_remaining)



# NPC
signal interacted_with_npc(npc)
signal npc_interaction_stopped(npc)
signal level_hint(hint)


# Sound
signal play_sound(sound, volume, pos)
signal play_music(level_type)

# Menu Related
signal menu_back()


# Config
signal sound_set_volume(new)
signal music_set_volume(new)
signal switch_fullscreen(value)
signal switch_shader(value)

# Tutorial
signal tutorial_finished()

# player
## Performs the upgrade
signal player_upgrades_do()
signal block_player_movement()
signal unblock_player_movement()
signal player_enter_door()
signal player_exit_door()
signal set_player_state(newState)
signal player_state_changed(newState)
signal change_player_animation(newAnim)
signal switched_weapon(newWeaponIndex)
signal drop_current_item()
signal pickup_item(newItem)
signal drop_guard()


# this blocks weapon input while block_player_movement only blocks movement
signal block_player_input()
signal unblock_player_input()


# Level
signal game_over()

# Holding selection button for 0.6 seconds
signal held_selection()
signal released_held_selection()








# Light Levels
#TODO: knightmare this is contradicting with visible_level_changed. The player do emit it but no one reacts to it. Please remove it if not necessary or adapt player code.
signal light_level_changed(newLevel) #Types.LightLevels

#TODO: Im not quite sure if we really need this one
signal allowed_detections_updated(value)


###############################################################################

# Global Event Connect Function
func connect(tSignal: String, target: Object, method: String, binds: Array = [], flags: int = 0):
	if Global.DEBUG and DEBUG_OUTPUT_ON_SIGNAL_CONNECT:
		print("Signal: [" + tSignal + "] -> " + str(target.name) + str(target))
	return .connect(tSignal, target, method, binds, flags)

# Prints the Signal Connection List
func debugGetSignalConnectionList(tSignal: String):
	print("Signal: [" + tSignal + "]")
	for sig in get_signal_connection_list(tSignal):
		print("-> " + str(sig.target.name)  + str(sig.target) + " - func:" + str(sig.method) )

# Deprecated: Global Event Connect Function
func connect_signal(tSignal: String, target: Object, method: String):
	#warning-ignore:return_value_discarded
	connect(tSignal, target, method)

