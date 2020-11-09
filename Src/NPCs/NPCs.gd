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
	elif Input.is_action_just_pressed("ui_cancel") and player_entered:
		Events.emit_signal("npc_interaction_stopped", self)


# function for loading dialogues
func load_dialogue() -> Dictionary:
	if dialogue_path == "":
		return {}
	var file := File.new()
	file.open(dialogue_path, file.READ)
	var dialogue = parse_json(file.get_as_text())
	return dialogue


func interact() -> void:
	# interacted_counter is probably only going to increase when changed level
	if has_dialogue(interacted_counter, dialogue_index):
		# gets the dict and gets "text" index from it
		say_dialogue_text(interacted_counter, dialogue_index)
		dialogue_index += 1
		return
		
	# resets dialogue index if you don't have the dialog and says it 
	dialogue_index = 0
	say_dialogue_text(interacted_counter, dialogue_index)
	dialogue_index += 1 # have to add dialogue_index unless you want npc to say same dialogue over and over again


# this function checks if dialogue exists from a passed interacted counter(first digit) and index(second digit)
func has_dialogue(counter, index) -> bool:
	return load_dialogue().has(str(counter) + str(index))

	
# this will get dialogue, make sure to check if has_dialogue first 
func get_dialogue(counter, index) -> Dictionary:
	return load_dialogue()[str(counter) + str(index)]


# this will take a counter and index and actually display it on screen
func say_dialogue_text(counter, index) -> void:
	var dialogue_text: String = get_dialogue(interacted_counter, dialogue_index)["text"]
	Events.emit_signal("hud_dialog_show", npc_name, npc_color, dialogue_text)


func _on_body_entered(body: Node) -> void:
	if body is Player:
		player_entered = true
		set_process(true)


func _on_body_exited(body: Node) -> void:
	if body is Player:
		player_entered = false
		set_process(false)


