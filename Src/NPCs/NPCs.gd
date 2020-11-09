class_name NPC
extends Area2D


export (String, FILE) var dialogue_path: String
export var npc_name: String
export var npc_color: String
var player_entered: bool = false
var interacted_counter: int = 0
var dialogue_index: int =  0


func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")
	set_process(false)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_entered:
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

	
# interacting function
func interact() -> void:
	var dialogue_text_array: Array = get_current_dialog_dict()["text"]

	if not dialogue_text_array.size() > dialogue_index:
		return
		
	var dialogue_text: String = dialogue_text_array[dialogue_index]
	Events.emit_signal("hud_dialog_show", npc_name, npc_color, dialogue_text)
	dialogue_index += 1


func get_current_dialog_dict() -> Dictionary:
	var dialogue := load_dialogue()
	if not dialogue.empty() and dialogue.has(str(interacted_counter)):
		var dialogue_dict: Dictionary = dialogue[str(interacted_counter)]
		return dialogue_dict
	
	return {}


func _on_body_entered(body: Node) -> void:
	if body is Player:
		player_entered = true
		set_process(true)


func _on_body_exited(body: Node) -> void:
	if body is Player:
		player_entered = false
		set_process(false)
