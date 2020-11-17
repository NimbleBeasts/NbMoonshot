extends Minigame

export var door_id:int
export var door_lock_level:int

export var max_x : int = 64
export var move_up : int = 64
export var hit_range : int = 6
export var switch_speed : float = 0.15

var controls_block = false
var cd:float
var rdir:float
var haccu:float

onready var pin = $LockpickSmallPin
onready var pin_goal = $LockpickSmallPinGoal

# Called when the node enters the scene tree for the first time.
func _ready():
	print( "Minilockpick start")
	#randomize start position for goal pin postion and pin itself
	randomize_start_pos()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if controls_block :
		return
		
	cd = cd - delta
	if cd < 0:
		rdir = rand_range(-3,3)
		cd = switch_speed
	
	var hor = rdir
	
	if Input.is_action_pressed("move_left"):
		haccu = haccu - 0.1
	if Input.is_action_pressed("move_right"):
		haccu = haccu + 0.1

	hor = hor + haccu
	pin.position = Vector2( clamp(pin.position.x + hor, -max_x, max_x), pin.position.y)	
	

func randomize_start_pos():
	randomize()
	pin.position = Vector2( rand_range(-max_x,max_x), pin.position.y )
	pin_goal.position = Vector2( rand_range(-max_x*0.5,max_x*0.5), pin_goal.position.y  )

func _input(event):
	if controls_block:
		return
	if Input.is_action_just_released("move_left") or Input.is_action_just_released("move_right"):
		haccu = 0
	if event.is_action_released("ui_up"):
		tap_pin();


func tap_pin():
	controls_block = true
	var hr
	if pin.position.x > pin_goal.position.x:
		hr = pin.position.x - pin_goal.position.x 
	else:
		hr = pin_goal.position.x - pin.position.x  
	print( abs(hr) )
	
	if( abs(hr) < hit_range ):
		print( " we got a winer ")
		pin.position = Vector2( pin.position.x, pin.position.y - move_up)
	else:
		print( " miss ")
		yield(get_tree().create_timer(0.25), "timeout")
		controls_block = false
