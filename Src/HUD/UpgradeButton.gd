tool

extends TextureButton

signal Upgrade_Button_Pressed(id)

export(int) var skill = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.frame = skill


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_UpgradeButton_button_up():
	emit_signal("Upgrade_Button_Pressed", skill)
