tool
extends HideOutBase

enum Types {Wooden, Metal}

var type = Types.Wooden

var isOpen: bool

#if carry body & E: open, throw body in, close
#if not carry body & E: open
#if not cary body & E & open: go in and close

func _ready():
	if type == Types.Wooden:
		$Sprite.texture = preload("res://Assets/HideOuts/WoodCloset.png")
	else:
		$Sprite.texture = preload("res://Assets/HideOuts/MetalCloset.png")


# input will only be processed if player is in the area
func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return
		
	if player.guardPickup.isDraggingGuard:
		print("open, throw body in, close")
		return

	if isOpen:
		print("go in and close")
		isOpen = false
	else:
		print("open")
		isOpen = true

