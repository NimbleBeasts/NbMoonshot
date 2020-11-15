extends Area2D

export(String) var text = ""


#signal hud_dialog_show(name, nameColor, text)
#signal hud_dialog_exited()

func _ready():
	connect("hud_dialog_exited", self, "remove")
	set_process(false)

func remove():
	print("pause")
	get_tree().paused = false
	queue_free()


func _on_ZoneTutorialBriefing_body_entered(body):
	if body.is_in_group("Player"):
		$DelayTimer.start()


func _on_ZoneTutorialBriefing_body_exited(body):
	if body.is_in_group("Player"):
		pass


func _on_DelayTimer_timeout():
	Events.emit_signal("hud_dialog_show", "Tutorial", "#88ebeb", text)
	get_tree().paused = true
