extends Minigame

var dict = {
	"POOP": "KFFK",
	"JACK": "MACK"
}

var visibilities = [
	"1001",
	"1010"
]

var invisibleCharacters = []
var selectedCharacterIndex = 0
var usedCharacters[]

var unitScene = preload("res://Src/Minigames/CryptogramMinigame/Unit.tscn")


func _ready() -> void:
	for i in dict.size():
		var key = dict.keys()[i]
		var unit = unitScene.instance()
		unit.word = key
		unit.visibilities = visibilities[i]
		unit.code = dict[key]
		unit.minigame = self
		$GridContainer.add_child(unit, true)


func _input(event: InputEvent) -> void:
	if selectedCharacterIndex >= invisibleCharacters.size():
		return
	if event is InputEventKey and event.is_pressed():
		# Gets the character and sets the text correctly
		var character = getSelectedCharacter()
		character.text = OS.get_scancode_string(event.scancode)
		character.setVisibility(true)
		selectedCharacterIndex += 1 # goes to next character
		# appends to an array incase the player wants to undo
		usedCharacters.append(character)
		# Gets the letter that the player was supposed to write. word is a string
		var targetLetter = character.unit.word[character.get_index()]
		# checks if player gave correct character and sets color accordingly
		if character.text == targetLetter:
			character.setColor(Color.green)
			return
		character.setColor(Color.red)


func getSelectedCharacter():
	return invisibleCharacters[selectedCharacterIndex]
