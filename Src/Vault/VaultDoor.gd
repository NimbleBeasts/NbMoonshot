extends Node2D


export var disabled_leaders : NodePath
export var tresure_sack : NodePath
var locked = true
var player

func open():
	$AnimationPlayer.play("open")
	$Vault.play()
	get_node(disabled_leaders).disabled = true
	locked = false




func _ready() -> void:
	connect("body_entered", self, "onBodyEntered")
	connect("body_exited", self, "onBodyExited")
	set_process_input(false)
	$VaultDoorShaftIMG.frame = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player != null and player.canInteract:
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
	if locked:
		return
	var ts = get_node(tresure_sack)
	if ts.global_position.y > 450:
		ts.global_position = Vector2(400, 320)
		ts.drop()



func _on_Button_body_entered(body):
	if body.is_in_group("Player"):
		$Sprite.material.set_shader_param("active", true)


func _on_Button_body_exited(body):
	if body.is_in_group("Player"):
		$Sprite.material.set_shader_param("active", false)
