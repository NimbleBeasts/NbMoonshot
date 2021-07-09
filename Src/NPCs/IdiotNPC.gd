extends Sprite




func _ready():
	#Random bobbing
	yield(get_tree().create_timer(randf()), "timeout")
	$AnimationPlayer.play("idle")
