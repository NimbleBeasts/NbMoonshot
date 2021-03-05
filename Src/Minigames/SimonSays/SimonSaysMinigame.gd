extends Minigame

enum Colors {Red, Green, Blue, Yellow}

var currentFlash
var flashedColors: Array = []
var flashAmount: int
var showTimer: Timer = Timer.new()
var inputtedButtons: Array = []
var targetInstance

func _ready() -> void:
	add_child(showTimer)
	showTimer.one_shot = true
	showTimer.connect("timeout", self, "showTimerTimeout")
	flashAmount = int(rand_range(4, 6))
	$ColorFlashTimer.connect("timeout", self, "flashColor")
	$ColorFlashTimer.start()
	
	var index = randi() % Colors.keys().size()
	currentFlash = $Lights.get_child(index)
	for i in range($Buttons.get_children().size()):
		var button = $Buttons.get_child(i)
		if button is TextureButton:
			button.connect("button_up", self,  "onButtonUp", [i])
			button.disabled = true

func flashColor():
	if flashedColors.size() >= flashAmount:
		for button in $Buttons.get_children():
			if button is TextureButton:
				button.disabled = false
		currentFlash.hide()
		$ColorFlashTimer.stop()
		$Buttons/Button.grab_focus()
		print("grabbed button focus")
		return
	currentFlash.enabled = false
	showTimer.start(0.1)

func showTimerTimeout() -> void:
	var index = randi() % Colors.keys().size()
	currentFlash = $Lights.get_child(index)
	print(Colors.keys()[index])
	flashedColors.append(index)
	currentFlash.enabled = true

func onButtonUp(buttonType: int) -> void:
	inputtedButtons.append(buttonType)
	var index = inputtedButtons.size() - 1
	if inputtedButtons[index] != flashedColors[index]:
		print("failed")
		set_result(Types.MinigameResults.Failed)
		close()
		return
	if inputtedButtons.size() == flashedColors.size():
		print("suceeded")
		Events.emit_signal("minigame_door_change_status" ,targetInstance, 0, true)
		set_result(Types.MinigameResults.Succeeded)
		close()
