extends Minigame

onready var plier: Area2D = $Plier

var goal_cuts: Array = []
var colors: Array = [Color.red, Color.green, Color.purple, Color.cyan]
var enum2text: Dictionary = {
	Types.WireColors.Green : "GREEN",
	Types.WireColors.Red : "RED",
	Types.WireColors.Blue : "BLUE",
	Types.WireColors.Purple : "PURPLE",
	
}
var wire_cut_status: Dictionary

func _ready() -> void:
	# basically loops through goal cuts, makes a new dict value 
	# if is in iteration Types.MinigameResults.WireColors, makes a new dict key of that and
	# sets the value to false
	for i in goal_cuts:
		wire_cut_status[i] = false

	# gives labels a unique color
	randomize()
	var rand_color1 = colors[randi() % colors.size()]
	var rand_color2 = colors[randi() % colors.size()]
	$Labels/Color1.set("custom_colors/font_color", rand_color1)
	$Labels/Color2.set("custom_colors/font_color", rand_color2)
	
	#gives labels correct text
	$Labels/Color1.text = enum2text[goal_cuts[0]]
	$Labels/Color2.text = enum2text[goal_cuts[1]]
	
func _process(delta: float) -> void:
	plier.global_position = get_global_mouse_position()
	

func _on_wire_cut(color_type: int) -> void:
	if wire_cut_status.has(color_type):
		wire_cut_status[color_type] = true
	else: # if the player cuts a wire that isn't in goal cuts
		set_result(Types.MinigameResults.Failed)
		close()
		
	if wire_cut_status.values()[0] and wire_cut_status.values()[1]:
		set_result(Types.MinigameResults.Succeeded)
		close()
	
