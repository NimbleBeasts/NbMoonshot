extends Minigame

var allowedColors: Array = [
	Color.red, Color.green, Color.blue, Color.yellow, 
]
var flashTimeMaximumAmount: int
var currentFlashTimeAmount: int = 0
onready var colorFlash: ColorRect = $ColorFlash

var flashedColors: Array = []
var inputFlashedColors: Array = []

func _ready() -> void:
	randomize()
	flashTimeMaximumAmount = int(rand_range(4, 6))
	print("Can flash for %s times" % flashTimeMaximumAmount)
	$ColorFlashTimer.start()
	$ColorFlashTimer.connect("timeout", self, "flashRandomColor")
	$AfterBlack.connect("timeout", self, "onAfterBlackTimeout")
	$AfterBlack.one_shot = true
	$Buttons.hide()
	
	for button in $Buttons.get_children():
		button.connect("button_up", self, "onButtonPressed", [button])

func flashRandomColor() -> void:
	if currentFlashTimeAmount >= flashTimeMaximumAmount:
		$ColorFlashTimer.stop()
		$Buttons.show()
		return
	colorFlash.color = Color.black
	$AfterBlack.start(0.3)

func onAfterBlackTimeout() -> void:
	colorFlash.color = allowedColors[randi() % allowedColors.size()]
	flashedColors.append(colorFlash.color)
	currentFlashTimeAmount += 1

func onButtonPressed(button) -> void:
	inputFlashedColors.append(button.modulate)
	#checks if the color that player inputted is equal to the flashed colors
	if inputFlashedColors == flashedColors:
		set_result(Types.MinigameResults.Succeeded)
		print("suceeded")
		close()
	#this gets the button color that the player was supposed to press and checks if its equal to the player the button pressed
	if button.modulate != flashedColors[inputFlashedColors.size() - 1]:
		print("failed")
		set_result(Types.MinigameResults.Failed)
		close()	
	
