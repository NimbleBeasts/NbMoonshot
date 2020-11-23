tool
extends Node2D

enum FlagType {Ustria, Russia, US}

export(FlagType) var flagType = FlagType.Ustria


# Called when the node enters the scene tree for the first time.
func _ready():
	match flagType:
		FlagType.Russia:
			$Sprite.texture = preload("res://Assets/Objects/FlagRussian.png")
		FlagType.US:
			$Sprite.texture = preload("res://Assets/Objects/FlagUsa.png")
		_:
			pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
