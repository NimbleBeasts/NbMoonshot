extends Area2D

export(String) var text = ""

var isShown = false

#signal hud_dialog_show(name, nameColor, text)
#signal hud_dialogue_exited()

func _ready():
	Events.connect("hud_dialogue_exited", self, "remove")
	set_process(false)

func remove():
	if isShown:
		get_tree().paused = false
		queue_free()


func _on_ZoneTutorialBriefing_body_entered(body):
	if body.is_in_group("Player"):
		if Global.player.dropItem():
			yield(get_tree().create_timer(0.3), "timeout")
		$DelayTimer.start()


func _on_ZoneTutorialBriefing_body_exited(body):
	if body.is_in_group("Player"):
		pass


func _on_DelayTimer_timeout():
	isShown = true
	Events.emit_signal("hud_dialog_show", "Tutorial", "#88ebeb", tr(text), true, Types.Potraits.Bot)
	Events.emit_signal("update_no_branch_button_state", true)
	Events.emit_signal("update_branch_button_state", false)
	Events.emit_signal("update_dialog_option", Types.DialogButtons.NoBranch, "Ok")
	get_tree().paused = true
