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
	wordContainer.unit = self
	codeContainer.unit = self
	codeContainer.word = code
	codeContainer.processVisibilites = false	
	wordContainer.initWord()
	codeContainer.initWord()
