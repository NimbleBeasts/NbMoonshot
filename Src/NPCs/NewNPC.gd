class_name NewNPC
extends Area2D

export (String, FILE) var dialoguePath: String
export var npcName: String
export var npcColor: String
export (Types.Potraits) var npcPotrait: int
export (Dictionary) var translations
export var lang: String

var loadedDialogue

var option0Branch
var option1Branch
var option2Branch

var currentBranch
var player: Player
var interactedCounter = 0 
var nextDialogue: String
var sayingDialogue: bool
var translation: Translation
var currentBranchID: String

# gonna comment this .... later 

func _ready() -> void:
	loadTranslation()
	set_process_input(false)
	Events.connect("no_branch_option_pressed", self, "onNoBranchButtonPressed")
	Events.connect("dialog_button_pressed", self, "onDialogButtonPressed")

	Events.connect("hide_dialog", self, "onDialogHidden")
	#warning-ignore:return_value_discarded
	connect("body_entered", self, "onBodyEntered")
	#warning-ignore:return_value_discarded
	connect("body_exited", self, "onBodyExited")
	loadDialogue()
	currentBranchID = "%s0" % interactedCounter
	if loadedDialogue.has(currentBranchID):
		setCurrentBranch(loadedDialogue[currentBranchID])


func _input(event: InputEvent) -> void:
	if not player or not event is InputEventKey:
		return
	if event.is_action_pressed("interact") and player.direction.x == 0 and currentBranch != {}:
		sayBranch(currentBranch)
		set_process_input(false)
		sayingDialogue = true

		
func onNoBranchButtonPressed() -> void:
	if not player:
		return
	if currentBranch.has("exitDialogue") and currentBranch["exitDialogue"]:
		exitDialogue()
		if currentBranch.has("nextDialogue") and loadedDialogue.has(currentBranch["nextDialogue"]):
			currentBranchID = currentBranch["nextDialogue"]
			setCurrentBranch(loadedDialogue.get(currentBranch[currentBranchID]))
		return
	if currentBranch.has("nextDialogue"):
		currentBranchID = currentBranch["nextDialogue"]
		setCurrentBranch(loadedDialogue.get(currentBranchID))
		sayBranch(currentBranch)
		return

	exitDialogue()


func onDialogButtonPressed(buttonType: int) -> void:
	if not player:
		return
	var exitDialogueKey = "exitDialogue" + str(buttonType)
	if currentBranch.has(exitDialogueKey) and currentBranch[exitDialogueKey]:
		exitDialogue()
		if loadedDialogue.has(currentBranch["branchID%s" % buttonType]):
			currentBranchID = currentBranch["branchID%s" % buttonType]
			setCurrentBranch(get("option%sBranch" % buttonType))
		return
	currentBranchID = currentBranch["branchID%s" % buttonType]
	setCurrentBranch(get("option%sBranch" % buttonType))
	sayBranch(currentBranch)
	

func onBodyEntered(body: Node) -> void:
	if body.is_in_group("Player"):
		set_process_input(true)
		player = body


func onBodyExited(body: Node) -> void:
	if body.is_in_group("Player"):
		set_process_input(false)
		player = null


func loadDialogue() -> void:
	var file = File.new()
	file.open(dialoguePath, File.READ)
	var dialogue: Dictionary = parse_json(file.get_as_text())
	loadedDialogue = dialogue


func loadTranslation() -> void:
	translation = translations.get(lang)


func sayBranch(branch: Dictionary) -> void:
	if translation == null:
		return
	Events.emit_signal("block_player_movement")
	Events.emit_signal("interacted_with_npc", self)
	var messageKey = "KEY_" + currentBranchID
	Events.emit_signal("hud_dialog_show", npcName, npcColor, translation.get_message(messageKey), false, npcPotrait)
	
	if branch.has("branchID0") or branch.has("branchID1") or branch.has("branchID2"):
		Events.emit_signal("update_no_branch_button_state", false)
		Events.emit_signal("update_branch_button_state", true)
		updateButtons(branch)
		updateOptionBranches(branch)
		return

	Events.emit_signal("update_branch_button_state", false)
	Events.emit_signal("update_no_branch_button_state", true)
	var choice = branch["choice"] if branch.has("choice") else "Ok"
	Events.emit_signal("update_dialog_option", Types.DialogButtons.NoBranch, choice)


func updateButtons(branch: Dictionary) -> void:
	if branch.has("branchChoice0"):
		Events.emit_signal("update_dialog_option", Types.DialogButtons.Option0, branch["branchChoice0"])
	if branch.has("branchChoice1"):
		Events.emit_signal("update_dialog_option", Types.DialogButtons.Option1, branch["branchChoice1"])
	if branch.has("branchChoice2"):
		Events.emit_signal("update_dialog_option", Types.DialogButtons.Option2, branch["branchChoice2"])

	
# this function is meant to be overriden
func checkForQuests() -> void:
	pass


func setInteractedCounter(value: int) -> void:
	if interactedCounter != value:
		interactedCounter = value
		currentBranchID = "%s0" % interactedCounter
		setCurrentBranch(loadedDialogue[currentBranchID])
		set_process_input(true)


func exitDialogue() -> void:
	checkForQuests()
	Events.emit_signal("hide_dialog")
	sayingDialogue = false

	
func onDialogHidden() -> void:
	if player:
		set_process_input(true)


func setCurrentBranch(newBranch) -> void:
	if currentBranch != newBranch:
		currentBranch = newBranch
		

func updateOptionBranches(branch: Dictionary) -> void:
	if branch.has("branchID0"):
		option0Branch = loadedDialogue.get(branch["branchID0"]) if loadedDialogue.has(branch["branchID0"]) else option0Branch
	else:
		Events.emit_signal("change_dialog_button_state", Types.DialogButtons.Option0, false)

	if branch.has("branchID1"):
		option1Branch = loadedDialogue.get(branch["branchID1"]) if loadedDialogue.has(branch["branchID1"]) else option1Branch
	else:
		Events.emit_signal("change_dialog_button_state", Types.DialogButtons.Option1, false)
	
	if branch.has("branchID2"):
		option2Branch = loadedDialogue.get(branch["branchID2"]) if loadedDialogue.has(branch["branchID2"]) else option2Branch
	else:
		Events.emit_signal("change_dialog_button_state", Types.DialogButtons.Option2, false)
