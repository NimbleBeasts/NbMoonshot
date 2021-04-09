extends Node2D


export(String, MULTILINE) var text = "This is a note text"
export(bool) var highlight = false
export(Types.NoteType) var type = Types.NoteType.SecretService
export (String, FILE) var translationCSVPath: String
export var translationKey: String 
export var tresorPath: NodePath

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
		if translationKey == "SECRET_CODE":
			# sets tresor code to a repeated two digit number 
			randomize()
			# gens a random 2 digit code
			var code := int(rand_range(10, 99))
			var stringCode = str(code) + str(code)
			text += " " + stringCode
			setTresorCode(int(stringCode))

	updateHighlight()
	Events.connect("hud_note_exited", self, "_hud_note_exited")


func setTresorCode(code: int) -> void:
	var tresor := get_node_or_null(tresorPath)
	if tresor:
		tresor.keyPadCode = code
		return
	printerr("Can't find tresor at %s. Reported by  %s" % [tresorPath, name])


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
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and Global.player.canInteract:
		if readable and not isReading:
			get_tree().set_input_as_handled()
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

		
