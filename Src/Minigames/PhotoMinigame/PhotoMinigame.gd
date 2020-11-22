extends Minigame

export (Texture) var targetTexture: Texture
export var countDownTime: int
export var pictureOffsetToCamera: Vector2
export var pictureTravelLength: float = 30
export var pictureTravelDuration: float = 2.0

var targetEnteredCamera: bool = false
var timeLeftString: String 
var time1: int
var time2: int
var targetColliderExtents
var cameraMoveSpeed

onready var timeSprite1: Sprite = $CountdownSprites/Time1
onready var timeSprite2: Sprite = $CountdownSprites/Time2
onready var countDownTimer: Timer = $CountdownTimer
onready var pictureTaken: Sprite = $PictureTaken
onready var pictureTakenTween: Tween = $PictureTakenTween


func _ready() -> void:
	pictureTakenTween.connect("tween_all_completed", self, "onPictureTweenAllCompleted")
	$Target/Sprite.texture = targetTexture
	$Camera.moveSpeed = cameraMoveSpeed
	$Target/CollisionShape2D.shape.extents = targetColliderExtents

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
			pictureTaken.texture = targetTexture
			pictureTaken.scale = $Target/Sprite.scale
			pictureTaken.position = $Camera.position + pictureOffsetToCamera
			pictureTakenTween.interpolate_property(pictureTaken, "position:y", pictureTaken.position.y, pictureTaken.position.y - pictureTravelLength, pictureTravelDuration, Tween.TRANS_LINEAR)
			pictureTakenTween.start()
			canCloseMinigame = false
			$Camera.canMove = false


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


func onPictureTweenAllCompleted() -> void:
	canCloseMinigame = true
	set_result(Types.MinigameResults.Succeeded)
	close()
