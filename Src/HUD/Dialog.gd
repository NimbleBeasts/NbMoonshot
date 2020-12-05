extends NinePatchRect



func _ready() -> void:
	Events.connect("update_branch_button_state", self, "changeOptionButtonsState")
	Events.connect("update_no_branch_button_state", self, "changeNoBranchButtonState")
	Events.connect("update_dialog_option", self, "onUpdateDialogOption")
	$Option0Button.connect("button_up", self, "onOption0ButtonUp")
	$Option1Button.connect("button_up", self, "onOption1ButtonUp")
	$NoBranchButton.connect("button_up", self, "onNoBranchButtonPressed")
	changeNoBranchButtonState(false)
	changeOptionButtonsState(false)


func onUpdateDialogOption(buttonType: int, newText: String) -> void:
	get_node(Types.DialogButtons.keys()[buttonType] + "Button").text = newText
	

func onOption0ButtonUp() -> void:
	Events.emit_signal("dialog_button_pressed", Types.DialogButtons.Option0)


func onOption1ButtonUp() -> void:
	Events.emit_signal("dialog_button_pressed", Types.DialogButtons.Option1)


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

	
