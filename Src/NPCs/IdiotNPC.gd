extends Sprite




func _ready():
	#Random bobbing
	randomize()

	yield(get_tree().create_timer(randf()*2.0), "timeout")
	$AnimationPlayer.play("idle")
