extends Minigame

signal selected_character_changed(newCharacter)

export var sentenceDeciphered: String
export var sentenceCipher: String
export var wordVisibilty: String

var dict: Dictionary = {}

var visibilities: Array = []

var selectableCharacters: Array = []
var invisibleCharacters: Array = []
var selectedCharacterIndex: int = 0
var cogWheelCharacters: Array = []

var unitScene : PackedScene = preload("res://Src/Minigames/CryptogramMinigame/Unit.tscn")

onready var wheelLetters: Node2D = $Wheel/Letters
onready var wheel: Node2D = $Wheel
onready var enterPosition: Position2D = $EnterPosition
onready var enterPositionLabel: Label = $EnterPosition/Label
onready var gridContainer: GridContainer = $GridContainer


func _ready() -> void:
	# converts the sentences (deciphered and ciphered) into arrays
	var decipheredWords = sentenceDeciphered.split(" ")
	var cipheredWords = sentenceCipher.split(" ")
	visibilities = wordVisibilty.split(" ")

	# makes a new unit, sets the word and code for every word in the deciphered array
	for i in range(decipheredWords.size()):
		var key = decipheredWords[i]
		dict[key] = cipheredWords[i]
		var unit = unitScene.instance()
		unit.word = key
		unit.visibilities = visibilities[i]
		unit.code = dict[key]
		unit.minigame = self
		gridContainer.add_child(unit, true)

	# initializes cogwheel
	for i in range(selectableCharacters.size()):
		var character = selectableCharacters[i]
		if cogWheelCharacters.has(character.correctText):
			continue
		cogWheelCharacters.append(character.correctText)
	updateCogWheelCharacters()

	# so it focuses on the first label
	emit_signal("selected_character_changed", getSelectedCharacter())

	# connects all of the signal + additional [label] to pass in the node that emmitted the signal
	for label in wheelLetters.get_children():
		label.get_node("Area2D").connect("area_entered", self, "onLetterAreaEntered", [label])
		label.get_node("Area2D").connect("area_exited", self, "onLetterAreaExited", [label])

	$Wheel/LabelRemove/Area2D.connect("area_entered", self, "onRemoveAreaEntered")
	$Wheel/LabelRemove/Area2D.connect("area_exited", self, "onRemoveAreaExited")


func _process(delta: float) -> void:
	# wheel rotation
	var rotate = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	wheel.rotation_degrees += rotate * 150 * delta


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		var selectionStatus = event.get_action_strength("move_up") - event.get_action_strength("move_down")
		if selectionStatus != 0:
			selectedCharacterIndex += selectionStatus
			if selectedCharacterIndex > selectableCharacters.size() - 1:
				selectedCharacterIndex = 0
			elif selectedCharacterIndex <= 0:
				selectedCharacterIndex = selectableCharacters.size() - 1
			emit_signal("selected_character_changed", getSelectedCharacter())
		if event.is_action_pressed("interact"):
			# if undo character is facing the thing
			if enterPositionLabel.text == "-":
				var character = getSelectedCharacter()
				for bruh in getAllDecipheredLettersThatAre(character.text):
					if bruh.text == "":
						return
					bruh.text = "-"
					bruh.setVisibility(true)
					bruh.setColor(Color.black)
					invisibleCharacters.append(bruh)
				return
			if enterPositionLabel.text != "":
				# gets selected character and sets its text
				var character = getSelectedCharacter()
				character.text = enterPositionLabel.text
				# gets the letter that the player was supposed to write. word is a string
				var targetLetter = character.unit.word[character.get_index()]
				# checks if the inputted letter is correct and assigns a color
				var correctColor = Color.green if character.text == targetLetter else Color.red
				for bruh in getAllCharactersThatHaveKey(character.keyLabel.text):
					bruh.text = character.text
					bruh.setVisibility(true)
					bruh.setColor(correctColor)
					invisibleCharacters.erase(bruh)
					if hasWon():
						set_result(Types.MinigameResults.Succeeded)
						close()
						return


func getSelectedCharacter():
	return selectableCharacters[selectedCharacterIndex]

	
func hasWon() -> bool:
	if invisibleCharacters != []:
		return false
	for character in selectableCharacters:
		if character.getColor() == Color.red:
			return false
	return true


func onLetterAreaEntered(area: Area2D, emitter: Label) -> void:
	if area == enterPosition:
		enterPositionLabel.text = emitter.text


func onLetterAreaExited(area: Area2D, emitter: Label) -> void:
	if emitter.text ==  enterPositionLabel.text:
		enterPositionLabel.text = ""


func onRemoveAreaEntered(area: Area2D) -> void:
	if area == enterPosition:
		enterPositionLabel.text = "-"


func onRemoveAreaExited(area: Area2D) -> void:
	if enterPositionLabel.text == "-":
		enterPositionLabel.text = ""


# function returns all characters from all units that are of text "letter"
func getAllCharactersThatHaveKey(letter: String) -> Array:
	var result: Array = []
	for unit in gridContainer.get_children():
		result += unit.getLabelsFromKey(letter)
	return result

func getAllDecipheredLettersThatAre(letter: String) -> Array:
	var result: Array = []
	for unit in gridContainer.get_children():
		result += unit.getDecipheredCharactersOf(letter)
	return result


func updateCogWheelCharacters() -> void:
	for i in range(cogWheelCharacters.size()):
		wheelLetters.get_child(i).text = cogWheelCharacters[i]
	

