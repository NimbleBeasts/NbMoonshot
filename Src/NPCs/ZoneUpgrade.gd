extends Area2D


var player = null

func _ready():
	set_process(false)

func _process(_delta):
	if player:
		if Input.is_action_just_pressed("interact"):
			Events.emit_signal("hud_upgrade_window_show")
			Events.emit_signal("block_player_movement")
		elif Input.is_action_just_pressed("ui_cancel"):
			Events.emit_signal("unblock_player_movement")


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
