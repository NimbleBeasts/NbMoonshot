class_name NewNPC
extends Area2D

export (String, FILE) var dialoguePath: String
export var npcName: String
export var npcColor: String
export (Types.Potraits) var npcPotrait: int
export (String, FILE) var enTranslationPath: String
export (String, FILE) var ruTranslationPath: String
export (String, FILE) var deTranslationPath: String
export var lang: String

var loadedDialogue
var option0Branch
var option1Branch
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
	currentBranch = loadedDialogue["%s0" % interactedCounter]
	currentBranchID = "%s0" % interactedCounter


func _input(event: InputEvent) -> void:
	if not player or not event is InputEventKey:
		return
	if event.is_action_pressed("interact") and player.direction.x == 0:
		sayBranch(currentBranch)
		set_process_input(false)
		sayingDialogue = true


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("cancel") and sayingDialogue:
			if currentBranch.has("lastDialogue"):
				currentBranch = loadedDialogue.get(currentBranch["lastDialogue"])
				currentBranchID = currentBranch["lastDialogue"]
				print(currentBranchID)
				sayBranch(currentBranch)


func onNoBranchButtonPressed() -> void:
	if not player:
		return
	if currentBranch.has("exitDialogue") and currentBranch["exitDialogue"]:
		exitDialogue()
		if currentBranch.has("nextDialogue") and loadedDialogue.has(currentBranch["nextDialogue"]):
			currentBranch = loadedDialogue.get(currentBranch["nextDialogue"])
		return
	if currentBranch.has("nextDialogue"):
		currentBranchID = currentBranch["nextDialogue"]
		currentBranch = loadedDialogue.get(currentBranch["nextDialogue"])
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
			print(currentBranchID)
			currentBranch = get("option%sBranch" % buttonType)
		return
	currentBranch = get("option%sBranch" % buttonType)
	sayBranch(currentBranch)


func onBodyEntered(body: Node) -> void:
	if body.is_in_group("Player"):
		set_process_input(true)
		set_process(true)
		player = body


func onBodyExited(body: Node) -> void:
	if body.is_in_group("Player"):
		set_process_input(false)
		set_process(false)
		player = null


func loadDialogue() -> void:
	var file = File.new()
	file.open(dialoguePath, File.READ)
	var dialogue: Dictionary = parse_json(file.get_as_text())
	loadedDialogue = dialogue


func loadTranslation() -> void:
	var translationPath = get(lang + "TranslationPath")
	if translationPath != null:
		translation = load(translationPath)


func sayBranch(branch: Dictionary) -> void:
	if translation == null:
		return
	Events.emit_signal("block_player_movement")
	Events.emit_signal("interacted_with_npc", self)
	var messageKey = "KEY_" + currentBranchID
	Events.emit_signal("hud_dialog_show", npcName, npcColor, translation.get_message(messageKey), false, npcPotrait)
	
	if branch.has("branchID0") and branch.has("branchID1"):
		Events.emit_signal("update_no_branch_button_state", false)
		Events.emit_signal("update_branch_button_state", true)
		updateButtons(currentBranch)
		if loadedDialogue.has(branch["branchID0"]):
			option0Branch = loadedDialogue.get(branch["branchID0"])
		if loadedDialogue.has(branch["branchID1"]):
			option1Branch = loadedDialogue.get(branch["branchID1"])
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

	
# this function is meant to be overriden
func checkForQuests() -> void:
	pass


func setInteractedCounter(value: int) -> void:
	if interactedCounter != value:
		interactedCounter = value
		currentBranch = loadedDialogue["%s0" % interactedCounter]
		currentBranchID = "%s0" % interactedCounter
		set_process_input(true)


func exitDialogue() -> void:
	checkForQuests()
	Events.emit_signal("hide_dialog")
	sayingDialogue = false

	
func onDialogHidden() -> void:
	if player:
		set_process_input(true)

