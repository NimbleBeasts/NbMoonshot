extends NinePatchRect

var dialogTyping: bool = false
var onOption0: bool = false
var noBranchFocusDelayTimer: Timer = Timer.new()

func _ready() -> void:
	add_child(noBranchFocusDelayTimer)
	noBranchFocusDelayTimer.connect("timeout", self, "onNoBranchFocusDelayTimeout")
	noBranchFocusDelayTimer.one_shot = true
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
	if event.is_action_pressed("move_right") or event.is_action_pressed("move_left"):
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
		# no idea why this needs a delay and the option ones doesn't 
		noBranchFocusDelayTimer.start(0.08)
		set_process_input(false)


func onDialogTypingChanged(value: bool) -> void:
	dialogTyping = value


func onNoBranchFocusDelayTimeout() -> void:
	$NoBranchButton.grab_focus()
