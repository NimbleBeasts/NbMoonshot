extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$MissionProgressUsa.updateValue(40, 20)
	$MissionProgressUssr.updateValue(50, 10)
	$MissionProgressUstria.updateValue(70, 40)
	


func updateProgress():
	show()
	$MissionProgressUsa.startAnimation()
	$MissionProgressUssr.startAnimation()
	$MissionProgressUstria.startAnimation()
	
	$BaseButton.grab_focus()


func _on_BaseButton_button_up():
	Events.emit_signal("hud_mission_progress_exited")
	hide()
