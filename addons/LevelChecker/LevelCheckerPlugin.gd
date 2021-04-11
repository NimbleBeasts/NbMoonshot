tool
extends EditorPlugin
class_name LevelCheckerPlugin

signal editor_visible

const editor_scn: PackedScene = preload("res://addons/LevelChecker/LevelChecker.tscn")
var editor: Control = editor_scn.instance()


func _enter_tree() -> void:
	add_tool_menu_item("LevelChecker", self, "_callback")

	
func _exit_tree() -> void:
	remove_tool_menu_item("LevelChecker")
	editor.free()


func _callback(_u):
	print("callback")
	add_child(editor)
	editor.popup()




