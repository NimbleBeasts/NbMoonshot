extends Minigame

export var sentenceDeciphered: String
export var sentenceCipher: String
export var wordVisibilty: String

var dict: Dictionary = {}

var visibilities: Array = []

var invisibleCharacters: Array = []
var selectedCharacterIndex: int = 0

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
	for i in range(invisibleCharacters.size()):
			var character = invisibleCharacters[i]
			if wheelLetters.get_child(i).text != character.text:
				wheelLetters.get_child(i).text = character.text

	# connects all of the signal + additional [label] to pass in the node that emmitted the signal
	for label in wheelLetters.get_children():
			label.get_node("Area2D").connect("area_entered", self, "onLetterAreaEntered", [label])


func _input(event: InputEvent) -> void:
	if selectedCharacterIndex >= invisibleCharacters.size():
		return
	if event is InputEventKey and event.is_pressed():
		var rotate = event.get_action_strength("move_right") - event.get_action_strength("move_left")
		wheel.rotation_degrees += rotate * 400 * get_process_delta_time()
		if event.is_action_pressed("interact"):
			if enterPositionLabel.text != "":
				# gets selected character and sets its text
				var character = getSelectedCharacter()
				character.text = enterPositionLabel.text
				character.setVisibility(true)
				invisibleCharacters.erase(character)
				# gets the letter that the player was supposed to write. word is a string
				var targetLetter = character.unit.word[character.get_index()]
				# checks if player gave correct character and sets color accordingly
				if character.text == targetLetter:
					character.setColor(Color.green)
					return
				character.setColor(Color.red)


func getSelectedCharacter():
	return invisibleCharacters[selectedCharacterIndex]


func onLetterAreaEntered(area: Area2D, emitter: Label) -> void:
	if area == enterPosition:
		enterPositionLabel.text = emitter.text
