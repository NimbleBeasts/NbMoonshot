extends Minigame

var clicked_array := []
#var goal_array := generate_randint_array(5)
export (Array, int) var goal_array: Array


func _ready() -> void:
	for button in $Control/GridContainer.get_children():
		button.connect("button_clicked", self, "_on_button_clicked")
	

	$GoalLabel.text = convert_array_to_string(goal_array)
	$ClickedLabel.text = convert_array_to_string(clicked_array)
	

func _on_button_clicked(num: int) -> void:
	clicked_array.append(num)
	
	$ClickedLabel.text = convert_array_to_string(clicked_array)
	
	# if got correct goal
	if clicked_array == goal_array:
		set_result(Types.MinigameResults.Succeeded)
		close()
	elif clicked_array.size() >= goal_array.size():
		set_result(Types.MinigameResults.Failed)
		close()
		

func convert_array_to_string(array: Array) -> String:
	var result = str(array)
	result.erase(result.length() - 1, 1)
	result.erase(0, 1)
	return result
