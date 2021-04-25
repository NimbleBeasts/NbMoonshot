tool
extends Area2D

export (Array, NodePath) var unlocks: Array

var player

func _ready() -> void:
	connect("body_entered", self, "onBodyEntered")
	connect("body_exited", self, "onBodyExited")
	set_process_input(false)
	
	$Sprite.set_material($Sprite.get_material().duplicate())


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and Global.player.canInteract:
		press()


func onBodyEntered(body: Node) -> void:
	if body.is_in_group("Player"):
		player = body
		set_process_input(true)


func onBodyExited(body: Node) -> void:
	if body.is_in_group("Player"):
		player = null
		set_process_input(false)


func press() -> void:
	#ignore button while its green
	if $Sprite.frame == 1:
		pass
	
	Events.emit_signal("play_sound", "button")
	#Events.emit_signal("hud_game_hint", "Button pressed")
	for thing in unlocks:
		var node = get_node(thing)
		if not node:
			printerr("Node Not Found")
			return
		if node.has_method("unlock"):
			node.unlock()
		else:
			node.toggleState()
	$Sprite.frame = 1;
	yield(get_tree().create_timer(1.0), "timeout")
	$Sprite.frame = 0;




func _on_Button_body_entered(body):
	if body.is_in_group("Player"):
		$Sprite.material.set_shader_param("active", true)


func _on_Button_body_exited(body):
	if body.is_in_group("Player"):
		$Sprite.material.set_shader_param("active", false)
