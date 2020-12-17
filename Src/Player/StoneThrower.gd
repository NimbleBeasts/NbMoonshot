extends Node

func _ready() -> void:
    set_process(false)

    
func _process(delta: float) -> void:
    if Input.is_action_just_pressed("weapon"):
        print("throw stone")