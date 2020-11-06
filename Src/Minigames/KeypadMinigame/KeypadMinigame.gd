extends Minigame

#var goal_array := generate_randint_array(5)
export (int) var goal: int

var input = ""

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
