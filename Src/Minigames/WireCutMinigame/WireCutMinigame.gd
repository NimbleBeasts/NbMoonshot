extends Minigame


var countdown: int = 7


onready var plier: Area2D = $Plier

#hacking in scissors for non mouse players
#onready var scissors: Sprite = $Sicssors
var wire_index = 0
var wires = []
var v_scale


var goal_cuts: Array = []
var colors: Array = ["#c93038", "#51c43f", "#852d66", "#63c2c9"]
var enum2text: Dictionary = {
	Types.WireColors.Green : "MINIGAME_WIRECUT_GREEN",
	Types.WireColors.Red : "MINIGAME_WIRECUT_RED",
	Types.WireColors.Blue : "MINIGAME_WIRECUT_BLUE",
	Types.WireColors.Purple : "MINIGAME_WIRECUT_PURPLE",
}

var wire_cut_status: Dictionary
var to_be_deactivated: Array

var wire_positions: Array = [
	Vector2(-2.4, -53.7),
	Vector2(-1.58, -19),
	Vector2(-2.75, 7.6),
	Vector2(0.1, 35)
]

func _ready() -> void:
	# gives the wires a random order
	# basically just shuffles the array and gives the children a position from it
	randomize()
	wire_positions.shuffle()
	for i in $Wires.get_children().size():
		$Wires.get_child(i).position = wire_positions[i]
		
	#sort his random pos for non mouse 
	wires = $Wires.get_children()
	wires.sort_custom(self,"sortup")
	
	
	# Goal cuts must be set!!
	assert(goal_cuts.size() == 2)

	# basically loops through goal cuts, makes a new dict value 
	# if is in iteration Types.MinigameResults.WireColors, makes a new dict key of that and
	# sets the value to false
	for i in goal_cuts:
		wire_cut_status[i] = false

	# gives labels a unique color
	randomize()
	var rand_color1 = colors[randi() % colors.size()]
	colors.erase(rand_color1) # so that the next one can't be the same
	var rand_color2 = colors[randi() % colors.size()]
	
	#$Labels/Label.bbcode_text = "Cut the [color="+rand_color1+"]" + enum2text[goal_cuts[0]] + "[/color] and [color="+rand_color2+"]" +enum2text[goal_cuts[1]]+ "[/color] wire."
	
	$Labels/Label.bbcode_text = tr("MINIGAME_WIRECUT_TEXT") % [rand_color1, tr(enum2text[goal_cuts[0]]), rand_color2, tr(enum2text[goal_cuts[1]])]
	
	
	#added timer
	run_countdown_timer()
	
	#hideMouse(true)
	

func hideMouse(yes):
	if yes:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _process(delta: float) -> void:
	v_scale =  OS.get_window_size() / Vector2(640, 360)
	plier.global_position = get_global_mouse_position() / v_scale
	

func _input(event):
		
	if event.is_action_pressed("move_up"):
		wire_index = wire_index + 1
		wire_index = clamp(wire_index,0,3)
		scissor_move()
	
	if event.is_action_pressed("move_down"):
		wire_index = wire_index - 1
		wire_index = clamp(wire_index,0,3)
		scissor_move()
		
func scissor_move():
	var wpos = wires[wire_index].global_position
	get_viewport().warp_mouse(wpos * v_scale)


func sortup(a,b):
	if a.global_position.y > b.global_position.y:
		return true
	return false

func _on_wire_cut(color_type: int) -> void:
	if wire_cut_status.has(color_type):
		wire_cut_status[color_type] = true
	else: # if the player cuts a wire that isn't in goal cuts
		set_result(Types.MinigameResults.Failed)
		hideMouse(false)
		close()
		
	if wire_cut_status.values()[0] and wire_cut_status.values()[1]:
		set_result(Types.MinigameResults.Succeeded)
		hideMouse(false)
		close()
	
func run_countdown_timer():
	while( countdown >= 0 ):
		if countdown > 9:
			var twochar = String(countdown)
			$WireTimer/dig5.frame = int(twochar[0])
			$WireTimer/dig6.frame = int(twochar[1])
		else:
			$WireTimer/dig5.frame = 0
			$WireTimer/dig6.frame = countdown
		yield(get_tree().create_timer(1.0), "timeout")
		if countdown == 0:
			set_result(Types.MinigameResults.Failed)
			close()
			return
		countdown = countdown - 1
