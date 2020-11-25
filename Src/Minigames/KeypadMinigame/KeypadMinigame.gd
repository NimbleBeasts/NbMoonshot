extends Minigame

#var goal_array := generate_randint_array(5)
export (int) var goal: int

var input = ""

var allowedKeys = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]


func _ready() -> void:
	for button in $Input.get_children():
		button.connect("button_clicked", self, "_on_button_clicked")
	

	$GoalLabel.text = str(goal)
	
	# Clear display
	clearDisplay()


# Clear the display
func clearDisplay():
	$Display/Digit0.frame = 10
	$Display/Digit1.frame = 10
	$Display/Digit2.frame = 10
	$Display/Digit3.frame = 10


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			var scanCodeString = OS.get_scancode_string(event.scancode)
			if scanCodeString in allowedKeys:
				var correctButton = get_node("Input/Button" + scanCodeString )
				correctButton.press()


func updateDisplay():
	var offset = input.length() - 1
	for i in range(offset + 1):
		get_node("Display/Digit" + str(i)).frame = int(input[offset - i])


func _on_button_clicked(num: String) -> void:
	if num == "§":  # Enter sign
		if goal == int(input):
			set_result(Types.MinigameResults.Succeeded)
		else:
			set_result(Types.MinigameResults.Failed)
		close()

	elif num == "*":
		input = ""
		$AnimationPlayer.play("clear")
	else:
		# Is a number
		if input.length() < 4:
			input += str(num)
			updateDisplay()


func _on_AnimationPlayer_animation_finished(anim_name):
	clearDisplay()

	
func playFailSound() -> void:
	Events.emit_signal("play_sound", "keypad_input_wrong")


func playSuccessSound() -> void:
	Events.emit_signal("play_sound", "keypad_input_correct")


