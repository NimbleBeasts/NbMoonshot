tool
extends GraphNode
class_name QuestNode


func _on_QuestNode_close_request():
	queue_free()

func get_quest() -> int:
	return int($LineEdit.text) if $LineEdit.text != "" else 9999
