extends NinePatchRect

var dialogTyping: bool = false
var onOption0: bool = false


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
	set_process_input(false)


func _input(event: InputEvent):
	if not event is InputEventKey:
		return
	if not event.is_action_pressed("move_right") or event.is_action_pressed("move_left"):
		return

	onOption0 = not onOption0
	if onOption0:
		$Option0Button.grab_focus()
		return
	$Option1Button.grab_focus()


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
	onOption0 = true
	if enabled:
		$Option0Button.grab_focus()
		set_process_input(true)


func changeNoBranchButtonState(enabled: bool) -> void:
	$NoBranchButton.visible = enabled
	$NoBranchButton.disabled = not enabled
	if enabled:
		$NoBranchButton.grab_focus()	
		set_process_input(false)


func onDialogTypingChanged(value: bool) -> void:
	dialogTyping = value
