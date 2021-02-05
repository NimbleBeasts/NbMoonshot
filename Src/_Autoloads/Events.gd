extends Node

#warning-ignore-all:unused_signal

const DEBUG_OUTPUT_ON_SIGNAL_CONNECT = false

###############################################################################
# Global Signal List
###############################################################################

###########################################################################
# Game Management
###########################################################################
## Starts a new Game
signal new_game(startLevel)
## Emitted if the tutorial was completed switching dialogue states
signal tutorial_finished()
## Emitted on instant detection or lifes over - Showing Game Over screen
signal game_over() #TODO: there is also hud_game_over
## Request sound to be played
signal play_sound(sound, volume, pos)
## Request music to be played
signal play_music(level_type)
## Emitted to go back in menu
signal menu_back()


###########################################################################
# Player
###########################################################################
## Blocks player movement
signal player_block_movement()
## Unblock player movement
signal player_unblock_movement()
## Blocks player input
signal player_block_input() #TODO: knight do we really need both variants?
	# No we don't right now, but we did when I added this
## Unblock player input 
signal player_unblock_input()
## This is used to change player states - e.g. dragging items, in closet ..
signal player_state_set(newState) #Types.PlayerStates
## This is emitted if the state of the player is changed
signal player_state_changed(newState)
## This is emitted to request animation (e.g. item pickup)
signal player_animation_change(newAnim)
## This signal is emitted to pick up an item
signal player_item_pickup(newItem)
## This signal is emitted to drop an item
signal player_item_drop()
## This signal is emitted to drop a guard
signal player_guard_drop()
## Performs the upgrade
signal player_upgrades_do()
## This is emitted when firing a taser
signal player_taser_fired(charges_remaining)
## Holding selection button for 0.6 seconds
signal player_selection_held()
## Releasing held button
signal player_selection_released()


###########################################################################
# Config Changes
###########################################################################
## Emitted if sound volume is changed in menus
signal cfg_sound_set_volume(new)
## Emitted if music volume is changed in menus
signal cfg_music_set_volume(new)
## Emitted if fullscreen mode is changed in menus
signal cfg_switch_fullscreen(value)
## Emitted if shader option is changed in menus
signal cfg_switch_shader(value)

###########################################################################
# Detection
###########################################################################
## Emitted when player makes noises - Audio Levels, audio_pos is the position where the audio notification was emitted for nearby guards
signal audio_level_changed(newLevel, audio_pos, emitter) #Types.AudioLevels
## Emitted when players visibility changes
signal visible_level_changed(newLevel)
## Emitted when the player is detected
signal player_detected(detection_type) # Types.DetectionLevels

###########################################################################
# Minigames
###########################################################################
## Emitted when a minigame is started
signal minigame_entered(minigame_type) #Types.Minigames
## Emitted when a minigame is closed
signal minigame_exited(result) #Types.Minigames
## Emitted when menu is called or player is detected
signal minigame_forcefully_close()
## Emitted by minigame to open/close door
signal minigame_door_change_status(door_name, lock_type, exec_anim) #exec anim is bool for switch state anim

###########################################################################
# HUD
###########################################################################
## Emitted to show note
signal hud_note_show(node, type, text)
## Emitted on closing note
signal hud_note_exited(node)
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
## Emitted to show dialogue
signal hud_dialog_show(name, nameColor, text, isMultipage, npcPotrait)
## Request closing dialogue
signal hud_dialogue_hide()
## Emitted on closing dialogue
signal hud_dialogue_exited()
## Emitted on changing light level
signal hud_light_level(level)

#TODO: rename remaining signals after I understand what they are doing :D
## Emitted when dialogue choices has to update text 
signal update_dialog_option(type, text)
## 
signal no_branch_option_pressed() #TODO: knightmare what does it actually do :D
	# It is a signal from when ok button is pressed :) so npc can react properly
## Emitted when choice button is pressed
signal dialog_button_pressed(buttonType)
## Emitted to switch visibility of choice buttons
signal update_branch_button_state(enabled)
## Emitted to switch visibility of "ok" button
signal update_no_branch_button_state(enabled) #TODO: knightmare isnt this just the opposite of the signal above?
## No Branch button is the ok button and Dialog button button for the branching
signal change_dialog_button_state(buttonType, enabled) #TODO: knightmare also dont really understand what this is for
# Disables or enables the button we want, options are in Types.DialogButtons. There's some naming conflicts here

###########################################################################
# The WTF Signal List :) 
###########################################################################

#####################################################################################
#TODO: Emitted but never listend to list - can be removed?:
signal hud_notification_show(type, node) #Types.HudNotificationType, self reference
signal hud_notification_exited()
signal hud_level_transition(level) #Mission briefing or -1 for returning to HQ
signal hud_level_transition_exited()
#####################################################################################

#TODO: knightmare what? do we need it? its pretty much the same as hud_game_hint
signal level_hint(hint)
# Check discord

#TODO: knightmare emitter and listener are in the same src file. Do we really need it?
signal switched_weapon(newWeaponIndex)

# Light Levels
#TODO: knightmare this is contradicting with visible_level_changed. The player do emit it but no one reacts to it. Please remove it if not necessary or adapt player code.
# Removed light_level_changed, guess its something only player needs to know about

#TODO: knightmare Im not quite sure if we really need this one
signal allowed_detections_updated(value)
# This is for that upgrade, normally a level only has 3 allowed detections but if you have the upgrade, you get 5
# So this is just a signal for hud to get correct number from BaseLevel

#TODO: knightmare from what I see we dont need it?!
signal dialog_typing_changed(value)
# Check discord

#TODO: knightmare I dont think we need this either emitter is a node of HUD receiver is the same node in HUD
# Removed skip_dialog

###############################################################################
# Global Event Functions
###############################################################################
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

