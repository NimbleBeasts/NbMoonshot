tool
extends GraphNode
class_name BaseBranch

var quest: String = ""

func _on_Branch_close_request():
	queue_free()
	

func _on_Branch_resize_request(new_minsize):
	rect_size = new_minsize

func has_only_one_connection() -> bool:
	return get_connection_input_count() == 0
