extends Node

#warning-ignore-all:unused_signal

const DEBUG_OUTPUT_ON_SIGNAL_CONNECT = false

###############################################################################
# Global Signal List
###############################################################################

# Level Management
signal new_game(startLevel)


# Light Levels
signal light_level_changed(newLevel) #Types.LightLevels
# Audio Levels, audio_pos is the position where the audio notification was emitted for nearby guards
signal audio_level_changed(newLevel, audio_pos) #Types.AudioLevels
signal visible_level_changed(newLevel)

# minigame
signal minigame_entered(minigame_type) #Types.Minigames
signal minigame_exited(result) #Types.Minigames
signal forcefully_close_minigame()

# Door open close
signal door_change_status(door_name, lock_type, exec_anim) #exec anim is bool for switch state anim

# HUD
signal hud_note_show(node, type, text)
signal hud_note_exited(node)
signal hud_dialog_show(name, nameColor, text, isMultipage)
signal hud_dialog_exited()
signal hud_notification_show(type, node) #Types.HudNotificationType, self reference
signal hud_notification_exited()
signal hud_upgrade_window_show()
signal hud_upgrade_window_exited()
signal hud_save_window_show()
signal hud_save_window_exited()
signal hud_level_transition(level) #Mission briefing or -1 for returning to HQ
signal hud_level_transition_exited()
signal hud_update_money(total, amount)
signal hide_dialog()
signal hud_mission_briefing(level)
signal hud_mission_briefing_exited()
signal hud_game_over()
signal hud_game_over_exited()
signal hud_game_hint(text)
signal hud_photo_flash()
signal hide_save()
signal update_upgrades()
signal dialog_typing_changed(value)
signal skip_dialog()

# dialog branching
signal update_dialog_option(type, text)
signal no_branch_option_pressed()

signal dialog_button_pressed(buttonType)

signal update_branch_button_state(enabled)
signal update_no_branch_button_state(enabled)

signal save_game()

# WebMonetization Pulse
signal web_monetization_pulse(isPaying)

# Detection
signal player_detected(detection_type) # Types.DetectionLevels
signal possible_detection_num_changed(value)
signal sure_detection_num_changed(value)
# Taser
signal taser_fired(charges_remaining)

# Allowed detections
signal allowed_detections_updated(value)

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
signal block_player_movement()
signal unblock_player_movement()
signal player_enter_door()
signal player_exit_door()
signal set_player_state(newState)
signal player_state_changed(newState)

# Level
signal game_over()

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
