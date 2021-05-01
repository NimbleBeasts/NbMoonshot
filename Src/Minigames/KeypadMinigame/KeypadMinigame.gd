extends Minigame

#var goal_array := generate_randint_array(5)
export (int) var goal: int

var input = ""

var allowedKeys = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

var btn_index = 0
onready var btn_selector:Sprite = $BtnSelector

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
				var correctButton = get_node("Input/Button" + scanCodeString)
				correctButton.press()
			
			# for enter and backspace
			if event.scancode == KEY_BACKSPACE:
				$Input/Button10.press()
			elif event.scancode == KEY_ENTER:
				$Input/Button11.press()
	
	if event is InputEventMouse:
		btn_selector.hide()
	else:
		moveByKeys(event)
		if event.is_action_pressed("interact"):
			$Input.get_child(btn_index).get_node("TextureButton").grab_focus()
			#$Input.get_child(btn_index).press()

func moveByKeys(event):

	if event.is_action_pressed("move_down"):#-3
		if btn_index > 2: btn_index = btn_index - 3
		btn_selector.show()
		
	if event.is_action_pressed("move_up"):#+3
		if btn_index < 9: btn_index = btn_index + 3
		btn_selector.show()
		
	if event.is_action_pressed("move_left"):#+1
		if not btn_index in [2,5,8,11] : btn_index = btn_index + 1
		btn_selector.show()
		
	if event.is_action_pressed("move_right"):#-1
		if not btn_index in [0,3,6,9] : btn_index = btn_index - 1
		btn_selector.show()
	
	btn_index = clamp( btn_index, 0, 11.1)
	btn_selector.global_position = $Input.get_child(btn_index).global_position

func updateDisplay():
	var offset = input.length() - 1
	for i in range(offset + 1):
		get_node("Display/Digit" + str(i)).frame = int(input[offset - i])


func _on_button_clicked(num: String) -> void:
	#set index so nonmouse continues form mouse
	if num == "§":
		btn_index = 0
	elif num == "*":
		btn_index = 1
	else:
		btn_index = int(num)+2
	
	
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
	$KeypadInputWrong.play()


func playSuccessSound() -> void:
	$KeypadInputCorrect.play()


