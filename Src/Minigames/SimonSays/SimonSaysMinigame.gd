extends Minigame

var allowedColors: Array = [
	Color.red, Color.green, Color.blue, Color.yellow, 
]
var flashTimeMaximumAmount: int
var currentFlashTimeAmount: int = 0

var flashedColors: Array = []
var inputFlashedColors: Array = []
var door_name
var lastButtonModulate

onready var colorFlash: Node2D = $ColorFlash
onready var buttonHolder: Control = $Buttons
onready var colorFlashSprite: Sprite = $ColorFlash/Sprite


func _ready() -> void:
	randomize()
	flashTimeMaximumAmount = int(rand_range(4, 6))
	$ColorFlashTimer.start()
	$ColorFlashTimer.connect("timeout", self, "flashRandomColor")
	$PressTimer.connect("timeout", self, "onAfterBlackTimeout")
	$PressTimer.one_shot = true
	$Buttons.hide()
	
	for i in range(buttonHolder.get_children().size()):
		var button = buttonHolder.get_child(i)
		button.connect("button_down", self, "onButtonDown", [button])
		button.connect("button_up", self, "onButtonUp", [button])
		button.connect("focus_entered", self, "onButtonFocusEntered", [button])
		button.connect("focus_exited", self, "onButtonFocusExited", [button])
		button.modulate = allowedColors[i]


func flashRandomColor() -> void:
	if currentFlashTimeAmount >= flashTimeMaximumAmount:
		$ColorFlashTimer.stop()
		$Buttons.show()
		$Buttons/Button.grab_focus()
		return
	$PressTimer.start(0.1)
	colorFlashSprite.frame = 1


func onAfterBlackTimeout() -> void:
	colorFlash.modulate = allowedColors[randi() % allowedColors.size()]
	colorFlashSprite.frame = 0
	flashedColors.append(colorFlash.modulate)
	currentFlashTimeAmount += 1


func onButtonUp(button) -> void:
	button.get_node("Sprite").frame = 0
	inputFlashedColors.append(button.modulate)
	#checks if the color that player inputted is equal to the flashed colors
	if inputFlashedColors == flashedColors:
		set_result(Types.MinigameResults.Succeeded)
		Events.emit_signal("door_change_status",door_name, 0, true)
		close()
	#this gets the button color that the player was supposed to press and checks if its equal to the player the button pressed
	if button.modulate != flashedColors[inputFlashedColors.size() - 1]:
		set_result(Types.MinigameResults.Failed)
		close()	

	
func onButtonDown(button) -> void:
	button.get_node("Sprite").frame = 1


func onButtonFocusEntered(button) -> void:
	lastButtonModulate = button.modulate
	button.modulate = Color.purple
	
func onButtonFocusExited(button) -> void:
	button.modulate = lastButtonModulate
