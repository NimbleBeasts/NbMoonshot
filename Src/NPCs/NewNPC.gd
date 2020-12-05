class_name NewNPC
extends Area2D

signal read_all_dialog

export (String, FILE) var dialoguePath: String
export var npcName: String
export var npcColor: String

var loadedDialogue
var option0Branch
var option1Branch
var currentBranch
var player: Player
var interactedCounter = 0 
var nextDialogue: String

# gonna comment this .... later 

func _ready() -> void:
	set_process(false)
	Events.connect("option0_pressed", self, "onOption0ButtonPressed")
	Events.connect("option1_pressed", self, "onOption1ButtonPressed")
	Events.connect("hide_dialog", self, "onDialogHidden")
	Events.connect("no_branch_option_pressed", self, "onNoBranchButtonPressed")
	connect("body_entered", self, "onBodyEntered")
	connect("body_exited", self, "onBodyExited")
	loadDialogue()
	currentBranch = loadedDialogue["%s0" % interactedCounter]


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player.direction.x == 0:
		sayCurrentBranch()
		Events.emit_signal("interacted_with_npc", self)
		Events.emit_signal("block_player_movement")
		set_process(false)

# these same fucntions pretty much do the same thing with small differences
# dunno if its worth squeezing them all into one function
func onNoBranchButtonPressed() -> void:
	if player:
		if currentBranch.has("exitDialogue") and currentBranch["exitDialogue"]:
			exitDialogue()
			return
		currentBranch = loadedDialogue.get(currentBranch["nextDialogue"])
		sayCurrentBranch()
			

func onOption0ButtonPressed() -> void:
	if player:
		if currentBranch.has("exitDialogue0") and ["exitDialogue0"]:
			exitDialogue()
			return
		currentBranch = option0Branch
		sayCurrentBranch()


func onOption1ButtonPressed() -> void:
	if player:
		if currentBranch.has("exitDialogue1") and currentBranch["exitDialogue1"]:
			exitDialogue()
			return
		currentBranch = option1Branch
		sayCurrentBranch()
		

func onBodyEntered(body: Node) -> void:
	if body.is_in_group("Player"):
		set_process(true)
		player = body


func onBodyExited(body: Node) -> void:
	if body.is_in_group("Player"):
		set_process(false)
		player = null


func loadDialogue() -> void:
	var file = File.new()
	file.open(dialoguePath, File.READ)
	var dialogue: Dictionary = parse_json(file.get_as_text())
	loadedDialogue = dialogue


func sayCurrentBranch() -> void:
	Events.emit_signal("interacted_with_npc", self)
	Events.emit_signal("hud_dialog_show", npcName, npcColor, currentBranch["text"], false)
	
	if currentBranch.has("branchID0"):
		Events.emit_signal("update_no_branch_button_state", false)
		Events.emit_signal("update_branch_button_state", true)
		updateBranchButtons()
		if loadedDialogue.has(currentBranch["branchID0"]):
			option0Branch = loadedDialogue.get(currentBranch["branchID0"])
		if loadedDialogue.has(currentBranch["branchID1"]):
			option1Branch = loadedDialogue.get(currentBranch["branchID1"])
		return

	Events.emit_signal("update_no_branch_button_state", true)
	Events.emit_signal("update_branch_button_state", false)
	var choice = currentBranch["choice"] if currentBranch.has("choice") else "Ok"
	Events.emit_signal("update_no_branch_option", choice)


func updateBranchButtons() -> void:
	if currentBranch.has("branchChoice0"):
		Events.emit_signal("update_option_button0", currentBranch["branchChoice0"])
	if currentBranch.has("branchChoice1"):
		Events.emit_signal("update_option_button1", currentBranch["branchChoice1"])

	
# this function is meant to be overriden
func checkForQuests() -> void:
	pass


func setInteractedCounter(value: int) -> void:
	if interactedCounter != value:
		interactedCounter = value
		currentBranch = loadedDialogue["%s0" % interactedCounter]
		set_process(true)


func exitDialogue() -> void:
	checkForQuests()
	Events.emit_signal("hide_dialog")

	
func onDialogHidden() -> void:
	set_process(true)
