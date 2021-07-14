extends Minigame

enum Colors {Red, Green, Blue, Yellow}

var currentFlash = null
var flashedColors: Array = []
var flashAmount: int
var showTimer: Timer = Timer.new()
var inputtedButtons: Array = []
var targetInstance



func _ready() -> void:
	add_child(showTimer)
	showTimer.one_shot = true
	showTimer.connect("timeout", self, "showTimerTimeout")
	flashAmount = 4 
	$ColorFlashTimer.connect("timeout", self, "flashColor")
	
	# var index = randi() % Colors.keys().size()
	# currentFlash = $Lights.get_child(index)
	for i in range($Buttons.get_children().size()):
		var button = $Buttons.get_child(i)
		if button is TextureButton:
			button.connect("button_up", self,  "onButtonUp", [i])
			button.disabled = true

	yield(get_tree().create_timer(0.75), "timeout")
	showTimerTimeout()
	$ColorFlashTimer.start()



func flashColor():
	if flashedColors.size() >= flashAmount:
		for button in $Buttons.get_children():
			if button is TextureButton:
				button.disabled = false
		currentFlash.hide()
		$ColorFlashTimer.stop()
		$Buttons/Button.grab_focus()
		return
	currentFlash.show()
	showTimer.start(0.1)

func showTimerTimeout() -> void:
	randomize()
	var index = randi() % Colors.keys().size()
	
	if currentFlash:
		currentFlash.hide()
	yield(get_tree().create_timer(0.1), "timeout")
	currentFlash = $Lights.get_child(index)
	flashedColors.append(index)
	currentFlash.show()
	currentFlash.get_children()[0].play()

func onButtonUp(buttonType: int) -> void:
	inputtedButtons.append(buttonType)
	
	match buttonType:
		0: 
			$Lights/Red.show()
			$Lights/Red/Beep.play()
		1:
			$Lights/Green.show()
			$Lights/Green/Beep.play()
		2:
			$Lights/Blue.show()
			$Lights/Blue/Beep.play()
		_:
			$Lights/Yellow.show()
			$Lights/Yellow/Beep.play()
	
	var index = inputtedButtons.size() - 1
	if inputtedButtons.size() > index and flashedColors.size() > index:
		if inputtedButtons[index] != flashedColors[index]:
			set_result(Types.MinigameResults.Failed)
			close()
			return
	if inputtedButtons.size() == flashedColors.size():
		Events.emit_signal("minigame_door_change_status" ,targetInstance, 0, true)
		set_result(Types.MinigameResults.Succeeded)
		close()
		
	#Clean code they say :D
	yield(get_tree().create_timer(0.5), "timeout")
	$Lights/Red.hide()
	$Lights/Green.hide()
	$Lights/Blue.hide()
	$Lights/Yellow.hide()
