tool
extends GraphNode
class_name LoveNode


func _on_LoveNode_close_request():
	queue_free()
	
func get_love_points() -> int:
	return int($LineEdit.text)

func get_id() -> String:
	return $ID.text
