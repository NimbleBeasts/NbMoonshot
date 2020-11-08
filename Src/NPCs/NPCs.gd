class_name NPC
extends Area2D

export (String, FILE) var dialogue_path: String
var player_entered: bool = false


func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")


func _process(delta: float) -> void:
	# _process will only get called if player is in the area so we don't need to put that additional check
	if Input.is_action_just_pressed("interact"):
		Events.emit_signal("interacted_with_npc", self)
		interact()


# function for loading dialogues
func load_dialogue() -> Dictionary:
	if dialogue_path == "":
		return {}
	var file := File.new()
	file.open(dialogue_path, file.READ)
	var dialogue = parse_json(file.get_as_text())
	return dialogue

func interact():
	pass

func _on_body_entered(body: Node) -> void:
	if body is Player:
		player_entered = true
		set_process(true)


func _on_body_exited(body: Node) -> void:
	if body is Player:
		player_entered = false
		set_process(false)
