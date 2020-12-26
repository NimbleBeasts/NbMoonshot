extends Node2D


export(String, MULTILINE) var text = "This is a note text"
export(bool) var highlight = false
export(Types.NoteType) var type = Types.NoteType.SecretService
export (String, FILE) var translationCSVPath: String
export var translationKey: String 

var readable = false
var isReading = false
var decouple = false
var translation: Translation


func _ready():
	add_to_group("HasTranslationSupport")
	loadTranslation()
	if translationKey != "":
		# finds text in the translation
		text = translation.get_message(translationKey)
	updateHighlight()
	Events.connect("hud_note_exited", self, "_hud_note_exited")


func updateHighlight():
	if highlight:
		$Sprite.frame = 0
		$NotifierArea.monitoring = true
	else:
		$Sprite.frame = 1
		$NotifierArea.monitoring = false 
		

func _process(_delta):
	# Skip this round to decouple inputs
	if decouple:
		decouple = false
		return
	
	if readable and not isReading:
		if Input.is_action_just_pressed("open_minigame"):
			isReading = true
			Events.emit_signal("hud_note_show", self, type, text)
			
			if highlight:
				$Sprite.frame = 1
				$Notifier.remove()
				highlight = false 
				updateHighlight()


func _hud_note_exited(node):
	if node == self:
		isReading = false
		decouple = true

func _on_ReadArea_body_entered(body):
	if body.is_in_group("Player"):
		readable = true

func _on_ReadArea_body_exited(body):
	if body.is_in_group("Player"):
		readable = false


func _on_NotifierArea_body_entered(body):
	if body.is_in_group("Player"):
		$Notifier.popup(Types.NotifierTypes.Exclamation)


func _on_NotifierArea_body_exited(body):
	if body.is_in_group("Player"):
		$Notifier.remove()
			
func loadTranslation() -> void:
	# finds the correct string path through the csv with some string magic, replacing the .csv with .locale.translation
	var translationPath: String = translationCSVPath.replace(".csv", "." + Global.languageLocale + ".translation")
	translation = load(translationPath)

		
