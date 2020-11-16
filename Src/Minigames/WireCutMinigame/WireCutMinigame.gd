extends Minigame


var atm_cd:int = 12


onready var plier: Area2D = $Plier

var goal_cuts: Array = []
var colors: Array = ["#c93038", "#51c43f", "#852d66", "#63c2c9"]
var enum2text: Dictionary = {
	Types.WireColors.Green : "GREEN",
	Types.WireColors.Red : "RED",
	Types.WireColors.Blue : "BLUE",
	Types.WireColors.Purple : "PURPLE",
	
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
	var rand_color2 = colors[randi() % colors.size()]
	
	$Labels/Label.bbcode_text = "Disable: Cut the [color="+rand_color1+"]" + enum2text[goal_cuts[0]] + "[/color] and [color="+rand_color2+"]" +enum2text[goal_cuts[1]]+ "[/color] wires"
	
	#added timer
	run_countdown_timer()

func _process(delta: float) -> void:
	var scale =  OS.get_window_size() / Vector2(640, 360)
	plier.global_position = get_global_mouse_position() / scale
	

func _on_wire_cut(color_type: int) -> void:
	if wire_cut_status.has(color_type):
		wire_cut_status[color_type] = true
	else: # if the player cuts a wire that isn't in goal cuts
		set_result(Types.MinigameResults.Failed)
		close()
		
	if wire_cut_status.values()[0] and wire_cut_status.values()[1]:
		set_result(Types.MinigameResults.Succeeded)
		close()
	
func run_countdown_timer():
	while( atm_cd >= 0 ):
		print(atm_cd)
		if atm_cd > 9:
			var twochar = String(atm_cd)
			$WireTimer/dig5.frame = int(twochar[0])
			$WireTimer/dig6.frame = int(twochar[1])
		else:
			$WireTimer/dig5.frame = 0
			$WireTimer/dig6.frame = atm_cd
		yield(get_tree().create_timer(1.0), "timeout")
		if atm_cd == 0:
			print("Failed")
			set_result(Types.MinigameResults.Failed)
			close()
			return
		atm_cd = atm_cd - 1

