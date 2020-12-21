extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$MissionProgressBar.updateValue(40, 20)
	$MissionProgressBar2.updateValue(50, 10)
	$MissionProgressBar3.updateValue(70, 40)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_button_up():
	$MissionProgressBar.startAnimation()
	$MissionProgressBar2.startAnimation()
	$MissionProgressBar3.startAnimation()
