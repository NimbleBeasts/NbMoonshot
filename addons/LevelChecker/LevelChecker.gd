tool
extends Control
class_name LevelChecker

var options = []

var parserNameToken = ""
var parserNameTokenLine = 0
var parserFindings = []

# Called when the node enters the scene tree for the first time.
func _ready():
	_on_UpdateList_button_up()


func createFinding(token: String, findLine: int, findLineText: String):
	parserFindings.append({"token": token, "findLine": findLine, "findLineText": findLineText})
	

func interpretLine(idx: int, line: String):
	if line.begins_with("[node name="):
		#New Token found - Replace old
		line = line.right(12)
		var end = line.find("\"",0)
		line = line.substr(0, end)
		parserNameToken = line 
		parserNameTokenLine = idx
	elif line.begins_with("position"):
		#Parse Position
		if line.find(".", 20) != -1:
			#Found 
			createFinding(parserNameToken, idx, line.right(20).trim_suffix(")"))

func updateFindings():
	$OptionButton/TextEdit.text = ""
	for line in parserFindings:
		$OptionButton/TextEdit.text += str(line.findLine) + ": " + line.token + " -> " + line.findLineText +  "\n"


func _on_Scan_button_up():
	parserFindings = []
	var activeFileId = $OptionButton.selected
	var file = File.new()
	file.open("res://Src/Levels/" + options[activeFileId], File.READ)
	
	var lineIdx = 1
	while not file.eof_reached():
		interpretLine(lineIdx, file.get_line())
		lineIdx += 1
	
	file.close()
	updateFindings()


func _on_UpdateList_button_up():
	var dir = Directory.new()
	
	if dir.open("res://Src/Levels/") == OK:
		$OptionButton.clear()
		options = []
		
		dir.list_dir_begin(true)
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.get_extension() == "tscn":
					options.append(file_name)
					$OptionButton.add_item(file_name, options.size() - 1)
			file_name = dir.get_next()
	dir.close()

func _on_FixFindings_button_up():
	pass # Replace with function body.
