extends Minigame

export (Texture) var targetTexture: Texture
export var countDownTime: int

var targetEnteredCamera: bool = false
var timeLeftString: String 
var time1: int
var time2: int

onready var timeSprite1: Sprite = $CountdownSprites/Time1
onready var timeSprite2: Sprite = $CountdownSprites/Time2
onready var countDownTimer: Timer = $CountdownTimer


func _ready() -> void:
	$Target/Sprite.texture = targetTexture
	# set collision shape extents on texture size, seems to work for me with a small offset that i can ignore
	# if reader knows how to do this properly, please edit this code
	var scale = OS.get_window_size() / Vector2(640, 360)
	$Target/CollisionShape2D.shape.extents = targetTexture.get_size() / scale / 2.4

	$Camera.connect("area_entered", self, "onCameraAreaEntered")
	$Camera.connect("area_exited", self, "onCameraAreaExited")
	$CountdownTimer.start(countDownTime)


func _process(delta: float) -> void:
	if str(int(countDownTimer.time_left)).length() > 1:
		setTimeLeftString(str(int(countDownTimer.time_left)))
	else:
		setTimeLeftString("0" + str(int(countDownTimer.time_left)))
		
	if targetEnteredCamera:
		if Input.is_action_just_pressed("interact"):
			print("suceeded photo minigame")
			set_result(Types.MinigameResults.Succeeded)
			close()
	
			
func onCameraAreaEntered(area: Area2D) -> void:
	if area.is_in_group("Target"):
		targetEnteredCamera = true


func onCameraAreaExited(area: Area2D) -> void:
	if area.is_in_group("Target"):
		targetEnteredCamera = false


func setTimeLeftString(value: String) -> void:
	if timeLeftString != value:
		timeLeftString = value
		timeSprite1.frame = int(timeLeftString.substr(0,1))
		timeSprite2.frame = int(timeLeftString.substr(1,1))

	# lose condition
	if countDownTimer.time_left < 0:
		print("failed photo minigame")
		set_result(Types.MinigameResults.Failed)
		close()
