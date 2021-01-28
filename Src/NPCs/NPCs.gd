class_name NPC
extends Area2D

signal read_all_dialog

export (String, FILE) var dialogue_path: String
export var npc_name: String
export var npc_color: String
var player_entered: bool = false
var interacted_counter: int = 0 setget setInteractedCounter
var dialogue_index: int =  0
var dialogueRead: bool = false
var dialogTyping: bool = false

var loadedDialogue := {}

func _ready() -> void:
	load_dialogue()
	Events.connect("dialog_typing_changed", self, "onDialogTypingChanged")
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")
	connect("read_all_dialog", self, "onReadAllDialogue")
	set_process(false)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_entered and Global.player.direction == Vector2(0,0) and not dialogTyping:
		# this is kind of a weird way to do this but it works :DDDDDDDDDDDD
		if not dialogueRead:
			Events.emit_signal("player_block_movement")
			interact()
		else:
			dialogueRead = false
	elif Input.is_action_just_pressed("ui_cancel") and player_entered:
		Events.emit_signal("player_unblock_movement")


# function for loading dialogues
func load_dialogue() -> void:
	if dialogue_path == "":
		return 
	var file := File.new()
	file.open(dialogue_path, file.READ)
	var dialogue = parse_json(file.get_as_text())
	loadedDialogue = dialogue


func interact() -> void:
	# interacted_counter is probably only going to increase when changed level
	if has_dialogue(interacted_counter, dialogue_index):
		# gets the dict and gets "text" index from it
		say_dialogue_text(interacted_counter, dialogue_index)
		# if it is on last dialogue, i.e it can't find anymore dialogues after this
		# it can emit "read_all_dialog"
		if not has_dialogue(interacted_counter, dialogue_index + 1):
			emit_signal("read_all_dialog")
			dialogue_index -= 1 # hacky way to make it say the same last dialogue each time you interact with it :DDDD

		dialogue_index += 1
		return

	dialogue_index = 0
	say_dialogue_text(interacted_counter, dialogue_index)
	dialogue_index += 1
	Events.emit_signal("player_unblock_movement")

# this function checks if dialogue exists from a passed interacted counter(first digit) and index(second digit) in the json file
func has_dialogue(counter, index) -> bool:
	 return loadedDialogue.has(str(counter) + str(index))

	
# this will get dialogue, make sure to check if has_dialogue first 
func get_dialogue(counter, index) -> Dictionary:
	if not loadedDialogue.has(str(counter) + str(index)):
		return {}
	return loadedDialogue[str(counter) + str(index)]

# this will take a counter and index and actually display it on screen
func say_dialogue_text(counter, index) -> void:
	var dialogueDict = get_dialogue(interacted_counter, dialogue_index)
	if dialogueDict.has("text"):
		var dialogue_text: String = dialogueDict["text"]
		Events.emit_signal("hud_dialog_show", npc_name, npc_color, dialogue_text)


func onReadAllDialogue() -> void:
	dialogueRead = true


func setInteractedCounter(value) -> void:
	interacted_counter = value
	dialogueRead = false


func _on_body_entered(body: Node) -> void:
	if body is Player:
		player_entered = true
		set_process(true)


func _on_body_exited(body: Node) -> void:
	if body is Player:
		player_entered = false
		set_process(false)


func onDialogTypingChanged(value: bool) -> void:
	dialogTyping = value
