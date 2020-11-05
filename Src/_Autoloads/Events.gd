extends Node

#warning-ignore-all:unused_signal

const DEBUG_OUTPUT_ON_SIGNAL_CONNECT = false

###############################################################################
# Global Signal List
###############################################################################

# Level Management
signal new_game()


# Light Levels
signal light_level_changed(newLevel) #Types.LightLevels
# Audio Levels
signal audio_level_changed(newLevel) #Types.AudioLevels

# Enter minigame
signal minigame_entered(minigame_type) #Types.Minigames
signal minigame_exited(result) #Types.Minigames

# WebMonetization Pulse
signal web_monetization_pulse(isPaying)

# Detection
signal player_detected(detection_type) # Types.DetectionLevels
signal possible_detection_num_changed(value)
signal sure_detection_num_changed(value)

# Noise
signal audio_notification(type) # Types.AudioNotifications

# Sound
signal play_sound(sound, volume, pos)

# Menu Related
signal menu_back()

# Config
signal switch_sound(value)
signal switch_music(value)
signal switch_fullscreen(value)

###############################################################################

# Global Event Connect Function
func connect(tSignal: String, target: Object, method: String, binds: Array = [], flags: int = 0):
	if Global.DEBUG and DEBUG_OUTPUT_ON_SIGNAL_CONNECT:
		print("Signal: [" + tSignal + "] -> " + str(target.name) + str(target))
	return .connect(tSignal, target, method)

# Prints the Signal Connection List
func debugGetSignalConnectionList(tSignal: String):
	print("Signal: [" + tSignal + "]")
	for sig in get_signal_connection_list(tSignal):
		print("-> " + str(sig.target.name)  + str(sig.target) + " - func:" + str(sig.method) )

# Deprecated: Global Event Connect Function
func connect_signal(tSignal: String, target: Object, method: String):
	#warning-ignore:return_value_discarded
	connect(tSignal, target, method)
