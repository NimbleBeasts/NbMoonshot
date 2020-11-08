extends Camera2D

func _ready() -> void:
	Events.connect("minigame_exited", self, "_on_minigame_exited")


func shake_camera() -> void:
	$AnimationPlayer.play("shake")


func _on_minigame_exited(result: int) -> void:
	if result == Types.MinigameResults.Failed:
		shake_camera()		
