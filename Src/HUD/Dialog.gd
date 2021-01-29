extends Control

var dialogTyping: bool = false
var currentOption: int = 0
var noBranchFocusDelayTimer: Timer = Timer.new()


func _ready() -> void:
	add_child(noBranchFocusDelayTimer)
	#warning-ignore:return_value_discarded
	noBranchFocusDelayTimer.connect("timeout", self, "onNoBranchFocusDelayTimeout")
	noBranchFocusDelayTimer.one_shot = true
	Events.connect("update_branch_button_state", self, "changeOptionButtonsState")
	Events.connect("update_no_branch_button_state", self, "changeNoBranchButtonState")
	Events.connect("update_dialog_option", self, "onUpdateDialogOption")
	#warning-ignore:return_value_discarded
	$Option0Button.connect("button_up", self, "onOption0ButtonUp")
	#warning-ignore:return_value_discarded
	$Option1Button.connect("button_up", self, "onOption1ButtonUp")
	#warning-ignore:return_value_discarded
	$Option2Button.connect("button_up", self, "onOption2ButtonUp")
	$NoBranchButton.connect("button_up", self, "onNoBranchButtonPressed")
	Events.connect("dialog_typing_changed", self, "onDialogTypingChanged")
	Events.connect("change_dialog_button_state", self, "changeButtonState")
	changeNoBranchButtonState(false)
	changeOptionButtonsState(false)


func onUpdateDialogOption(buttonType: int, newText: String) -> void:
	get_node(Types.DialogButtons.keys()[buttonType] + "Button").updateLabel(newText)


func changeButtonState(buttonType: int, enabled) -> void:
	var node = get_node(Types.DialogButtons.keys()[buttonType] + "Button")
	node.visible = enabled
	node.disabled = not enabled


func onOption0ButtonUp() -> void:
	if not dialogTyping:
		Events.emit_signal("dialog_button_pressed", Types.DialogButtons.Option0)
		return
	skipDialog()


func onOption1ButtonUp() -> void:
	if not dialogTyping:
		Events.emit_signal("dialog_button_pressed", Types.DialogButtons.Option1)
		return
	skipDialog()


func onOption2ButtonUp() -> void:
	if not dialogTyping:
		Events.emit_signal("dialog_button_pressed", Types.DialogButtons.Option2)
		return
	skipDialog()


func onNoBranchButtonPressed() -> void:
	if not dialogTyping:
		Events.emit_signal("no_branch_option_pressed")
		return
	skipDialog()

	
func changeOptionButtonsState(enabled: bool) -> void:
	# loops through the button and does it's stuff
	var i = 0
	while i < 3:
		var node = get_node("Option%sButton" % i)
		node.visible = enabled
		node.disabled = not enabled
		i += 1
	currentOption = 0
	if enabled:
		$Option0Button.grab_focus()

		
func changeNoBranchButtonState(enabled: bool) -> void:
	$NoBranchButton.visible = enabled
	$NoBranchButton.disabled = not enabled
	if enabled:
		# no idea why this needs a delay and the option ones doesn't 
		noBranchFocusDelayTimer.start(0.08)


func onDialogTypingChanged(value: bool) -> void:
	dialogTyping = value


func onNoBranchFocusDelayTimeout() -> void:
	$NoBranchButton.grab_focus()


func skipDialog() -> void:
	$Text.visible_characters = $Text.text.length()
