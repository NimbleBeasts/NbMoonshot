tool
extends EditorPlugin
class_name DialogueEditorPlugin

signal editor_visible

const editor_scn: PackedScene = preload("res://addons/DialogueEditor/DialogueEditor.tscn")
var editor: Control = editor_scn.instance()


func _enter_tree() -> void:
	add_control_to_bottom_panel(editor, "Dialogue Editor")
	connect("editor_visible", editor, "index_files")

	
func _exit_tree() -> void:
	remove_control_from_bottom_panel(editor)
	editor.free()
	

