extends Node

var dog: Dog


func _ready() -> void:
	set_process_input(false)


func _input(event: InputEvent) -> void:
	if not event is InputEventKey or dog == null:
		return

	if event.is_action_pressed("interact"):
		dog.feed()
	

func onPlayerBodyEntered(body: Node) -> void:
	if body.is_in_group("Dog"):
		set_process_input(true)
		dog = body


func onPlayerBodyExited(body: Node) -> void:
	if body.is_in_group("Dog"):
		set_process_input(false)
		dog = null
