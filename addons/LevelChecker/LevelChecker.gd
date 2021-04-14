tool
extends Control
class_name LevelChecker

var options = []

var parserNameToken = ""
var parserNameTokenLine = 0
var parserFindings = []

var newFile = []

# Called when the node enters the scene tree for the first time.
func _ready():
	_on_UpdateList_button_up()


func createFinding(token: String, findLine: int, findLineText: Vector2):
	parserFindings.append({"token": token, "findLine": findLine, "findLineText": findLineText})
	

func interpretLine(idx: int, line: String):
	if line.begins_with("[node name="):
		#New Token found - Replace old
		var nl = line.right(12)
		var end = nl.find("\"",0)
		nl = nl.substr(0, end)
		parserNameToken = nl 
		parserNameTokenLine = idx
		newFile.append(line)
	elif line.begins_with("position"):
		#Parse Position
		if line.find(".", 20) != -1:
			#Found
			print(line)
			var value = str2var(line.right(11))
			print(value)
			createFinding(parserNameToken, idx, value)
			#Fix for new file
			newFile.append("position = Vector2 ( " + str(int(value.x)) + ", " + str(int(value.y)) + " )")
		else:
			newFile.append(line)
	else:
		newFile.append(line)
	

func updateFindings():
	if parserFindings.size() > 0:
		$OptionButton/TextEdit.text = ""
		for line in parserFindings:
			$OptionButton/TextEdit.text += str(line.findLine) + ": " + line.token + " -> " + str(line.findLineText) +  "\n"
	else:
		$OptionButton/TextEdit.text = "No findings"

func _on_Scan_button_up():
	parserFindings = []
	var activeFileId = $OptionButton.selected
	var file = File.new()
	file.open("res://Src/Levels/" + options[activeFileId], File.READ)
	
	newFile = []
	
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
	if newFile.size() > 0:
		$OptionButton/TextEdit.text += "Storing File"
		var saveFile = File.new()
		saveFile.open("res://Src/Levels/TestWrite.tscn", File.WRITE)
		for line in newFile:
			saveFile.store_line(line)
		saveFile.close()
	else:
		$OptionButton/TextEdit.text = "No file loaded"
