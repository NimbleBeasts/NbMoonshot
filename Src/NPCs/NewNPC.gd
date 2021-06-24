class_name NewNPC
extends Area2D

export (String, FILE) var dialoguePath: String
export var npcName: String
export var npcColor: String
export (Types.Potraits) var npcPotrait: int
export (String, FILE) var translationCSVPath: String

var loadedDialogue

var option0Branch
var option1Branch
var option2Branch

var currentBranch
var player: Player
var interactedCounter = 0 
var nextDialogue: String
var sayingDialogue: bool

var currentBranchID: String

# gonna comment this .... later 

func _ready() -> void:
	set_process_input(false)
	Events.connect("no_branch_option_pressed", self, "onNoBranchButtonPressed")
	Events.connect("dialog_button_pressed", self, "onDialogButtonPressed")

	Events.connect("hud_dialogue_hide", self, "onDialogHidden")
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
		if currentBranch != {}:
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
	if currentBranch.has("afterLoveDialogue"):
		currentBranchID = currentBranch["afterLoveDialogue"]
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


func sayBranch(branch: Dictionary) -> void:
	Events.emit_signal("player_block_movement")
	var messageKey = "KEY_" + currentBranchID
	Events.emit_signal("hud_dialog_show", npcName, npcColor, tr(messageKey), false, npcPotrait)
	
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
	# 3 is chosen because that is the current amount of possible branches that dialog may have
	# loops through, checks if branch has respective key which has some text, and then updates the respective dialog button with the text
	for i in range(3):
		if branch.has("branchID%s" % i):
			# gets the correct key from the csv file "CHOICE_03_0" where 03 is the branch code in json file and 0 is the branch id
			# 0 is first branch, 1 is second branch and so on
			var key: String = "CHOICE_%s_%s" % [currentBranchID, i]
			Events.emit_signal("update_dialog_option", i, tr(key))

			
# this function is meant to be overriden
func checkForQuests() -> void:
	pass


func setInteractedCounter(value: int) -> void:
	if interactedCounter != value:
		interactedCounter = value
		currentBranchID = "%s0" % interactedCounter
		if Global.returnedFromSabotageMission:
			print("returned from sabotage mission")
			currentBranchID += "A"
		if loadedDialogue.has(currentBranchID):
			setCurrentBranch(loadedDialogue[currentBranchID])
		set_process_input(true)


func exitDialogue() -> void:
	checkForQuests()
	Events.emit_signal("hud_dialogue_hide")
	sayingDialogue = false

	
func onDialogHidden() -> void:
	if player:
		set_process_input(true)


func setCurrentBranch(newBranch) -> void:
	if currentBranch != newBranch:
		currentBranch = newBranch
		

func updateOptionBranches(branch: Dictionary) -> void:
	# checks for the branchID that the json might have and updates the optionNumberBranch or disables the respective button
	# 3 is chosen because that's the amount of supported branches in the dialog system (currently)
	for i in range(3):
		if branch.has("branchID%s" % i):
			var correctVar = "option" + str(i) + "Branch"
			set(correctVar, loadedDialogue.get(branch["branchID" + str(i)]))
		else:
			Events.emit_signal("change_dialog_button_state", i, false)
