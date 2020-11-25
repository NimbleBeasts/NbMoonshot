extends Node2D


var player_in_fov = null


func _ready():
	set_process(false)

func _process(_delta: float) -> void:
	if player_in_fov:
		print( Global.player.visible_level )
		match Global.player.visible_level:
			Types.LightLevels.FullLight:
				animation("detected")
			Types.LightLevels.BarelyVisible:
				animation("suspect")
			#Types.LightLevels.Dark:
			#	animation("idle")
				
func animation(anim):
	#print("anim: ", anim)
	if $AnimationPlayer.current_animation != anim:
		$AnimationPlayer.seek(0,true)
		$AnimationPlayer.play(anim)

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		player_in_fov = body
		set_process(true)


func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		player_in_fov = null
		$AnimationPlayer.play("idle")
		set_process(false)
