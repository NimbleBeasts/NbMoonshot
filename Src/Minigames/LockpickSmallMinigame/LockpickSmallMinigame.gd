extends Minigame

export var difficulty:int
export var run_anim:bool

export var max_x : int = 64
export var move_up : int = 64
export var hit_range : int = 6
export var switch_speed : float = 0.1
var lp_upgrade : float = 1

var controls_block = false
var cd:float
var rdir:float
var haccu:float

onready var pin = $LockpickSmallPin
onready var pin_goal = $LockpickSmallPinGoal

var targetInstance = null setget setTarget

func setTarget(instance):
	print("set: " + str(instance))
	targetInstance = instance

# Called when the node enters the scene tree for the first time.
func _ready():
	init_game()
	if Types.UpgradeTypes.Lockpick_Level2 in Global.gameState.playerUpgrades:
		#print("running with upgraded lockpick")
		lp_upgrade = lp_upgrade * 0.5


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	if controls_block :
		return
		
	cd = cd - delta
	if cd < 0:
		rdir = (Global.rng.randi_range(0,2)*2 -1)
		cd = switch_speed
	
	var speed = 0.5 * difficulty * lp_upgrade
	var hor = rdir * speed
	
	if Input.is_action_pressed("move_left"):
		haccu = haccu - 0.1
	if Input.is_action_pressed("move_right"):
		haccu = haccu + 0.1

	hor = hor + haccu
	pin.position = Vector2( clamp(pin.position.x + hor, -max_x, max_x), pin.position.y)	
	

func init_game():
	#print( "Minilockpick start")
	controls_block = false
	randomize() #random start postions
	pin.position = Vector2( rand_range(-max_x,max_x), pin.position.y )
	pin_goal.position = Vector2( rand_range(-max_x*0.5,max_x*0.5), pin_goal.position.y  )

func _input(event):
	if controls_block:
		return
	if Input.is_action_just_released("move_left") or Input.is_action_just_released("move_right"):
		haccu = 0
	if event.is_action_pressed("interact"):
		tap_pin();


func tap_pin():
	controls_block = true
	var hr
	if pin.position.x > pin_goal.position.x:
		hr = pin.position.x - pin_goal.position.x 
	else:
		hr = pin_goal.position.x - pin.position.x  
	
	if( abs(hr) < hit_range ):
		Events.emit_signal("play_sound", "lockpick_hit")
		pin.position = Vector2( pin.position.x, pin.position.y - move_up)
		yield(get_tree().create_timer(0.25), "timeout")
		set_result(Types.MinigameResults.Succeeded)
		Events.emit_signal("minigame_door_change_status", targetInstance, 0, run_anim)
		close()
	else:
		Events.emit_signal("play_sound", "lockpick_miss")
		yield(get_tree().create_timer(0.25), "timeout")
		set_result(Types.MinigameResults.Failed)
		close()
