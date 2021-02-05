tool
extends Control


export(Types.LevelTypes) var nation = Types.LevelTypes.USA

# Called when the node enters the scene tree for the first time.
func _ready():
	match nation:
		Types.LevelTypes.USA:
			$Foreground.texture_progress = preload("res://Assets/HUD/ProgressBar/BarBlue.png")
		Types.LevelTypes.USSR:
			$Foreground.texture_progress = preload("res://Assets/HUD/ProgressBar/BarRed.png")
		_:
			$Foreground.texture_progress = preload("res://Assets/HUD/ProgressBar/BarGreen.png")


func updateValue(startValue, gain):
	$Foreground.value = startValue
	$Background.value = int(min(100, startValue + gain))
	$Label.set_text(str(startValue) + "%")
	$Tween.interpolate_property($Foreground, "value", startValue, $Background.value, 1, Tween.TRANS_LINEAR) #TODO make it dependend on gain size

func startAnimation():
	$Tween.start()

func _on_Tween_tween_step(object, key, elapsed, value):
	$Label.set_text(str(int($Foreground.value)) + "%")
