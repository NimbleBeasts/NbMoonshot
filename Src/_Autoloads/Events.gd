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

# Enter minigame
signal minigame_entered(minigame_type) #Types.Minigames
signal minigame_exited(result) #Types.Minigames

# Door open close
signal door_change_status(door_name, lock_type, exec_anim) #exec anim is bool for switch state anim

# HUD
signal hud_note_show(type, text)
signal hud_note_exited()
signal hud_dialog_show(name, nameColor, text)
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

# Sound
signal play_sound(sound, volume, pos)

# Menu Related
signal menu_back()

# Config
signal switch_sound(value)
signal switch_music(value)
signal switch_fullscreen(value)

# Tutorial
signal tutorial_finished()


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
