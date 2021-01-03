extends GridContainer

export var word: String
var visibilities
var characterScene: PackedScene = preload("res://Src/Minigames/CryptogramMinigame/Character.tscn")
var processVisibilites: bool = true
var minigame
var unit
var codeContainer


func initWord() -> void:
	columns = word.length()
	for i in range(word.length()):
		var letter = word[i]
		var character = characterScene.instance()
		add_child(character, true)
		character.text = letter
		if codeContainer != null:
			character.keyLabel = codeContainer.get_child(i)
		character.unit = unit
		if processVisibilites and bool(int(visibilities[i])) == false:
			character.setVisibility(false)
			minigame.invisibleCharacters.append(character)
