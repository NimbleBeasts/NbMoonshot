extends Minigame

onready var plier: Area2D = $Plier

export (Array, Types.WireColors) var goal_cuts: Array = []

var wire_cut_status: Dictionary

func _ready() -> void:
	for i in goal_cuts:
		wire_cut_status[i] = false


func _process(delta: float) -> void:
	plier.global_position = get_global_mouse_position()
	

func _on_wire_cut(color_type: int) -> void:
	if wire_cut_status.has(color_type):
		wire_cut_status[color_type] = true
		
	if wire_cut_status[goal_cuts[0]] and wire_cut_status[goal_cuts[1]]:
		set_result(Types.MinigameResults.Succeeded)
		close()
