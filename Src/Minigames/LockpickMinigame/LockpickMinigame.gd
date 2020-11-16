extends Minigame

var pins = []
var atm_at:int = 0
var seq:int = 0
var controlsBlock = false

var try:int = 6
onready var lockpick = $LockpickInside
onready var try_ui = $TryUI

class LockPin:
	var gameobj : Sprite
	var rand_pos : Vector2
	var order_pos : int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Lockpick started")
	randomize()
	
	try = 6
	controlsBlock = false
	update_try()


	#set random order
	var order = [0,1,2,3]
	order.shuffle()
	
	#randomize pin positions for looks 
	for n in range(4):
		var lp =  LockPin.new()
		lp.gameobj = get_node( "Pins/LockpickPin"+ str(n+1) )
		lp.rand_pos = Vector2( lp.gameobj.position.x, rand_range(-23.0,-33.0) )
		lp.gameobj.position = lp.rand_pos
		lp.order_pos = order.pop_back()
		pins.append( lp )	

	#random locpick pos
	atm_at = int(rand_range(0,3.4))
	lockpick.position = Vector2( pins[ atm_at ].gameobj.position.x , lockpick.position.y )



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	if seq == 4:
		if $LockpickLock.rotation_degrees > -88:
			$LockpickLock.rotate(-2 * delta)
		if $LockpickLock.rotation_degrees < -88 and $LockpickLock.rotation_degrees > -90:
			$LockpickLock.rotation_degrees = -90
			seq = 5
			set_result(Types.MinigameResults.Succeeded)
			close()

		
func _input(event):
	if controlsBlock:
		return
	
	if event.is_action_released("move_right"):
		move_lockpick(true)
	if event.is_action_released("move_left"):
		move_lockpick(false)
	if event.is_action_released("ui_up"):
		tap_pin();



func move_lockpick(dir:bool):
	if dir:
		atm_at = clamp( atm_at + 1, 0, 3 )
	else:
		atm_at = clamp( atm_at - 1, 0, 3 )
	lockpick.position = Vector2( pins[atm_at].gameobj.position.x, lockpick.position.y )
	
func tap_pin():
	#print("taping ",atm_at )
	if pins[atm_at].order_pos == seq:
		seq = seq + 1
		pins[atm_at].gameobj.position = Vector2( pins[atm_at].gameobj.position.x , -42 )
		if seq == 4:
			print("Sucess")
			# don't forget to close it
			set_result(Types.MinigameResults.Succeeded)
			close()
			controlsBlock = true
	else:
		shake_ping()
		update_try()


func shake_ping():
	controlsBlock = true
	
	var pin_go = pins[atm_at].gameobj
	var start_pos = pin_go.position

	for i in range(5):
		pin_go.position = start_pos + Vector2( rand_range(0,2), rand_range(0,2))
		yield(get_tree().create_timer(0.05), "timeout")
	pin_go.position = start_pos
	
	#reset all pins. 
	yield(get_tree().create_timer(0.1), "timeout") 
	seq = 0
	for p in range(4):
		pins[p].gameobj.position = pins[p].rand_pos
	controlsBlock = false

func update_try():
	try = try - 1
	$TryUI.text = "Tries: " + String(try)
	if try == 0:
		print("Failed")
		set_result(Types.MinigameResults.Failed)
		close()
