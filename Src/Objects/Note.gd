extends Node2D


export(String, MULTILINE) var text = "This is a note text"
export(bool) var highlight = false
export(Types.NoteType) var type = Types.NoteType.SecretService

var readable = false


func _ready():
	updateHighlight()
	set_process(false)


func updateHighlight():
	if highlight:
		$Sprite.frame = 0
		$NotifierArea.monitoring = true
	else:
		$Sprite.frame = 1
		$NotifierArea.monitoring = false 
		
func _process(_delta):
	if readable:
		if Input.is_action_just_pressed("open_minigame"):
			Events.emit_signal("hud_note_show", type, text)
			if highlight:
				$Sprite.frame = 1
				$Notifier.remove()
				highlight = false 
				updateHighlight()


func _on_ReadArea_body_entered(body):
	if body.is_in_group("Player"):
		readable = true

func _on_ReadArea_body_exited(body):
	if body.is_in_group("Player"):
		readable = false


func _on_NotifierArea_body_entered(body):
	if body.is_in_group("Player"):
		set_process(true)
		$Notifier.popup(Types.NotifierTypes.Exclamation)


func _on_NotifierArea_body_exited(body):
	if body.is_in_group("Player"):
		set_process(false)
		$Notifier.remove()
			
