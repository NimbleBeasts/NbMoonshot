extends NinePatchRect



func _ready() -> void:
	Events.connect("update_branch_button_state", self, "changeOptionButtonsState")
	Events.connect("update_no_branch_button_state", self, "changeNoBranchButtonState")
	Events.connect("update_option_button0", self, "onUpdateOptionButton0")
	Events.connect("update_option_button1", self, "onUpdateOptionButton1")
	Events.connect("update_no_branch_option", self, "onUpdateNoBranchOption")
	$Option0Button.connect("button_up", self, "onOption0ButtonUp")
	$Option1Button.connect("button_up", self, "onOption1ButtonUp")
	$NoBranchButton.connect("button_up", self, "onNoBranchButtonPressed")
	changeNoBranchButtonState(false)
	changeOptionButtonsState(false)


func onUpdateOptionButton0(newText: String) -> void:
	$Option0Button.text = newText


func onUpdateOptionButton1(newText: String) -> void:
	$Option1Button.text = newText


func onUpdateNoBranchOption(newText: String) -> void:
	$NoBranchButton.text = newText


func onOption0ButtonUp() -> void:
	Events.emit_signal("option0_pressed")


func onOption1ButtonUp() -> void:
	Events.emit_signal("option1_pressed")


func onNoBranchButtonPressed() -> void:
	Events.emit_signal("no_branch_option_pressed")


func onNoDialogBranch() -> void:
	changeOptionButtonsState(false)
	changeNoBranchButtonState(true)

	
func changeOptionButtonsState(enabled: bool) -> void:
	$Option0Button.visible = enabled
	$Option0Button.disabled = not enabled
	$Option1Button.visible = enabled
	$Option1Button.disabled = not enabled


func changeNoBranchButtonState(enabled: bool) -> void:
	$NoBranchButton.visible = enabled
	$NoBranchButton.disabled = not enabled

	