extends Minigame

export var normal_color:Color = Color.white
export var active_color:Color = Color.red

export var door_name:String
export var difficulty:int
export var run_anim:bool

onready var btn_parrent = $GridContainer
onready var timer_slider = $Timer/TimerSlider

onready var textureNormal = preload("res://Assets/Minigames/LightButton.png")
onready var textureActive = preload("res://Assets/Minigames/LightButtonActive.png")

var btn_index = 0
var old_index = 0
onready var btn_selector = $BtnSelector

func _input(event):
	if event is InputEventMouse:
		btn_selector.hide()
	else:
		moveByKeys(event)
	#if event.is_action_pressed("interact"):
		#$GridContainer.get_child(btn_index).emit_signal("button_up")

func moveByKeys(event):
	
	if event.is_action_pressed("move_up"):#-3
		if btn_index > 2: btn_index = btn_index - 3
		btn_selector.show()
		
	if event.is_action_pressed("move_down"):#+3
		if btn_index < 9: btn_index = btn_index + 3
		btn_selector.show()
		
	if event.is_action_pressed("move_right"):#+1
		if not btn_index in [2,5,8] : btn_index = btn_index + 1
		btn_selector.show()
		
	if event.is_action_pressed("move_left"):#-1
		if not btn_index in [0,3,6] : btn_index = btn_index - 1
		btn_selector.show()
	
	btn_index = clamp( btn_index, 0, 8.1)
	if old_index != btn_index:
		old_index = btn_index
		btn_selector.global_position = $GridContainer.get_child(btn_index).rect_global_position
		$GridContainer.get_child(btn_index).grab_focus()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	init_game()


func init_game():
	randomize()
	#random tunrn one light
	var flip_one:int = round( rand_range(0, btn_parrent.get_child_count()-0.6) )
	switch_color(flip_one)
	
	#make start button on flip_one
	btn_index = flip_one
	
	#connect buttons
	for x in range(9):
		var btn = btn_parrent.get_child(x)
		btn.connect("button_up",self,"_on_button_click",[x])
		
	#full timer
	timer_slider.value = timer_slider.max_value
	set_process(true)
	
func _process(delta):
	var nw = timer_slider.value - delta 
	timer_slider.value = nw
	
	if( timer_slider.value < 1 ):
		set_process(false)
		set_result(Types.MinigameResults.Failed)
		close()

func switch_color(i):
	var btn:TextureButton = btn_parrent.get_child(i)
	if btn.texture_normal == textureActive:
		btn.texture_normal = textureNormal
	else:
		btn.texture_normal = textureActive

func get_neigbhurs(i):
	var ng = []
	if not i in [2,5,8]: #right
		ng.append(i+1)
	if not i in [0,3,6]: #left
		ng.append(i-1)
	if not i in [6,7,8]: #up
		ng.append(i + 3)
	if not i in [0,1,2]: #down
		ng.append(i - 3)
	return ng
	
func _on_button_click(what):
	
	btn_index = what
	switch_color(what)
	for n in get_neigbhurs(what):
		switch_color(n)
	check_win()

func check_win():
	for b in btn_parrent.get_children():
		if b.texture_normal == textureNormal:
			return
	yield(get_tree().create_timer(0.25), "timeout")
	set_result(Types.MinigameResults.Succeeded)
	Events.emit_signal("minigame_door_change_status",door_name, 0, run_anim)
	close()
	
