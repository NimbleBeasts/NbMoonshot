extends Area2D

export (Array, NodePath) var guards: Array

var player
var playingmusic = false

func _ready() -> void:
	connect("body_entered", self, "onBodyEntered")
	connect("body_exited", self, "onBodyExited")
	set_process_input(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player != null and player.canInteract:
		press()
		$Jukebox.play()
		get_tree().set_input_as_handled()
		

func onBodyEntered(body: Node) -> void:
	if body.is_in_group("Player"):
		player = body
		set_process_input(true)

func onBodyExited(body: Node) -> void:
	if body.is_in_group("Player"):
		player = null
		set_process_input(false)

func _on_Button_body_entered(body):
	if body.is_in_group("Player"):
		$Sprite.material.set_shader_param("active", true)


func _on_Button_body_exited(body):
	if body.is_in_group("Player"):
		$Sprite.material.set_shader_param("active", false)


func press():
	if playingmusic:
		return
		
	playingmusic = true
	$SoundParticle.emitting = true
	
	SteamWorks.setAchievement("STEAM_ACH_7")
	
	for guardPath in guards:
		var guard = get_node(guardPath)
		if not guard.inDistractMode:
			guard.distractMode()
	
	yield(get_tree().create_timer(10.0), "timeout")
	playingmusic = false
	$SoundParticle.emitting = false


func _on_Jukebox_finished():
	$Jukebox.play()
