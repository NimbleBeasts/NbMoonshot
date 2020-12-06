extends NinePatchRect

var dialogTyping: bool = false


func _ready() -> void:
	Events.connect("update_branch_button_state", self, "changeOptionButtonsState")
	Events.connect("update_no_branch_button_state", self, "changeNoBranchButtonState")
	Events.connect("update_dialog_option", self, "onUpdateDialogOption")
	$Option0Button.connect("button_up", self, "onOption0ButtonUp")
	$Option1Button.connect("button_up", self, "onOption1ButtonUp")
	$NoBranchButton.connect("button_up", self, "onNoBranchButtonPressed")
	Events.connect("dialog_typing_changed", self, "onDialogTypingChanged")
	changeNoBranchButtonState(false)
	changeOptionButtonsState(false)


func onUpdateDialogOption(buttonType: int, newText: String) -> void:
	get_node(Types.DialogButtons.keys()[buttonType] + "Button").updateLabel(newText)
	

func onOption0ButtonUp() -> void:
	if not dialogTyping:
		Events.emit_signal("dialog_button_pressed", Types.DialogButtons.Option0)
		return
	Events.emit_signal("skip_dialog")

func onOption1ButtonUp() -> void:
	if not dialogTyping:
		Events.emit_signal("dialog_button_pressed", Types.DialogButtons.Option1)
		return
	Events.emit_signal("skip_dialog")


func onNoBranchButtonPressed() -> void:
	if not dialogTyping:
		Events.emit_signal("no_branch_option_pressed")
		return
	Events.emit_signal("skip_dialog")


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

	
func onDialogTypingChanged(value: bool) -> void:
	dialogTyping = value
