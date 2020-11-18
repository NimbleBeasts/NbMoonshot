extends Minigame

export var normal_color:Color = Color.white
export var active_color:Color = Color.red

export var door_id:int
export var difficulty:int
export var play:bool

onready var btn_parrent = $GridContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	init_game()


func init_game():
	randomize()
	#random tunrn one light
	var flip_one:int = round( rand_range(0, btn_parrent.get_child_count()-0.6) )
	switch_color(flip_one)
	
	#connect buttons
	for x in range(9):
		var btn = btn_parrent.get_child(x)
		btn.connect("button_up",self,"_on_button_click",[x])

func switch_color(i):
	var btn:TextureButton = btn_parrent.get_child(i)
	if btn.modulate == Color.green :
		btn.modulate = Color.white
	else:
		btn.modulate = Color.green

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
	switch_color(what)
	for n in get_neigbhurs(what):
		switch_color(n)
	check_win()

func check_win():
	for b in btn_parrent.get_children():
		if b.modulate == normal_color:
			return
	print("Win")
	yield(get_tree().create_timer(0.25), "timeout")
	set_result(Types.MinigameResults.Succeeded)
	Events.emit_signal("door_change_status",door_id, 0, play)
	
