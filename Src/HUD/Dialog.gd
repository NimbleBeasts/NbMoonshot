extends Control

var dialogTyping: bool = false
var currentOption: int = 0
var noBranchFocusDelayTimer: Timer = Timer.new()
var isOption: bool = false
var holdTimer: Timer = Timer.new()

func _ready() -> void:
	set_process_input(false)
	add_child(noBranchFocusDelayTimer)
	add_child(holdTimer)
	holdTimer.wait_time = 1
	holdTimer.one_shot = true
	holdTimer.connect("timeout", self, "skipDialog")
	#warning-ignore:return_value_discarded
	noBranchFocusDelayTimer.connect("timeout", self, "onNoBranchFocusDelayTimeout")
	noBranchFocusDelayTimer.one_shot = true
	Events.connect("update_branch_button_state", self, "changeOptionButtonsState")
	Events.connect("update_no_branch_button_state", self, "changeNoBranchButtonState")
	Events.connect("update_dialog_option", self, "onUpdateDialogOption")
	#warning-ignore:return_value_discarded
	$vbox/Option0Button.connect("button_down", self, "onOption0ButtonUp")
	#warning-ignore:return_value_discarded
	$vbox/Option1Button.connect("button_down", self, "onOption1ButtonUp")
	#warning-ignore:return_value_discarded
	$vbox/Option2Button.connect("button_down", self, "onOption2ButtonUp")
	$vbox/NoBranchButton.connect("button_down", self, "onNoBranchButtonPressed")
	Events.connect("dialog_typing_changed", self, "onDialogTypingChanged")
	Events.connect("change_dialog_button_state", self, "changeButtonState")
	changeNoBranchButtonState(false)
	changeOptionButtonsState(false)


func _input(event: InputEvent) -> void:
	if event.is_action_released("interact"):
		holdTimer.stop()
		if isOption:
			$vbox/Option0Button.grab_focus()
		else:
			$vbox/NoBranchButton.grab_focus()


func onUpdateDialogOption(buttonType: int, newText: String) -> void:
	get_node("vbox/" + Types.DialogButtons.keys()[buttonType] + "Button").text = newText


func changeButtonState(buttonType: int, enabled) -> void:
	var node = get_node("vbox/" + Types.DialogButtons.keys()[buttonType] + "Button")
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
		var node = get_node("vbox/Option%sButton" % i)
		node.visible = enabled
		node.disabled = not enabled
		i += 1
	currentOption = 0
	if enabled:
		# $vbox/Option0Button.grab_focus()
		set_process_input(true)
		isOption = true
		holdTimer.start()

		
func changeNoBranchButtonState(enabled: bool) -> void:
	$vbox/NoBranchButton.visible = enabled
	$vbox/NoBranchButton.disabled = not enabled
	if enabled:
		# no idea why this needs a delay and the option ones doesn't 
		# noBranchFocusDelayTimer.start(0.08)
		set_process_input(true)
		isOption = false
		holdTimer.start()


func onDialogTypingChanged(value: bool) -> void:
	dialogTyping = value


func onNoBranchFocusDelayTimeout() -> void:
	$vbox/NoBranchButton.grab_focus()


func skipDialog() -> void:
	$Text.visible_characters = $Text.text.length()
