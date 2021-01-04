extends Control

var word: String = ""
var code: String = ""
var visibilities: String
var minigame

onready var wordContainer = $Word
onready var codeContainer = $Code


func _ready() -> void:
	wordContainer.word = word
	wordContainer.minigame = minigame
	wordContainer.visibilities = visibilities
	wordContainer.codeContainer = codeContainer
	wordContainer.unit = self
	codeContainer.unit = self
	codeContainer.word = code
	codeContainer.codeContainer = null
	codeContainer.processVisibilites = false
	codeContainer.initWord()
	wordContainer.initWord()


func getLabelsFromKey(key: String) -> Array:
		var result := []
		for character in wordContainer.get_children():
			if character.keyLabel.text == key:
				result.append(character)
		return result

		
# func getDecipheredCharactersOf(letter: String) -> Array:
# 	var result := []
# 	for character in wordContainer.get_children():
# 		if character.text == letter:
# 			result.append(character)
# 	return result
