extends Area2D


var player = null

func _ready():
	set_process(false)

func _process(delta):
	if player:
		if Input.is_action_just_pressed("interact"):
			Events.emit_signal("hud_upgrade_window_show")

func _on_ZoneUpgrade_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		set_process(true)
		Events.emit_signal("hud_notification_show", Types.HudNotificationType.BuyZone, self)


func _on_ZoneUpgrade_body_exited(body):
	if body.is_in_group("Player"):
		player = null
		set_process(false)
		Events.emit_signal("hud_notification_exited")
