extends Node2D


export(String) var text = "This is a note text"
export(bool) var highlight = false

var readable = false
var alreadyRead = false

func _ready():
	updateHighlight()

func updateHighlight():
	if highlight:
		$Sprite.frame = 0
		$NotifierArea.monitoring = true
	else:
		$Sprite.frame = 1
		$NotifierArea.monitoring = false
		
func _process(delta):
	if readable:
		if Input.is_action_just_pressed("open_minigame"):
			Events.emit_signal("hud_note_show", text)
			if highlight:
				$Sprite.frame = 1
				$Notifier.remove()
				highlight = false
				updateHighlight()


func _on_ReadArea_body_entered(body):
	if body.is_in_group("Player"):
		print("read enter")
		readable = true

func _on_ReadArea_body_exited(body):
	if body.is_in_group("Player"):
		print("read exit")
		readable = false

func _on_NotifierArea_body_entered(body):
	if body.is_in_group("Player"):
		$Notifier.popup(Types.NotifierTypes.Exclamation)


func _on_NotifierArea_body_exited(body):
	if body.is_in_group("Player"):
		$Notifier.remove()
			
