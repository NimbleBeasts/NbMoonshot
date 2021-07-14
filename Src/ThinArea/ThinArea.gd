tool
class_name ThinArea
extends Area2D

enum Width {Width3 = 0, Width4 = 1}

export var reduced_up = 0
export var reduced_down = 0
export var disabled: bool = false setget setDisabled
export var isLadder: bool
export(Width) var width = Width.Width4 setget setWidth

const textures = [
	"res://Assets/ThinArea/ThinArea3x.png",
	"res://Assets/ThinArea/ThinArea4x.png"
]

onready var destination_up_position: Vector2 = $DestinationUp.global_position  - Vector2(0, reduced_up * 8)
onready var destination_down_position: Vector2 = $DestinationDown.global_position - Vector2(0, reduced_down * 8)

func _ready():
	if isLadder:
		return

	var shape = RectangleShape2D.new()
	shape.extents = Vector2(16, 4)
	$CollisionShape2D.shape = shape
	$StaticBody2D/CollisionShape2D.shape = shape


func setDisabled(val):
	self.monitoring = !val
	disabled = val

func setWidth(_width):
	if isLadder:
		return

	$Sprite.texture = load(textures[_width])
	var shape = $CollisionShape2D.shape
	
	match _width:
		Width.Width3:
			shape.extents.x = 12
			$CollisionShape2D.position.x = 12
			$StaticBody2D/CollisionShape2D.position.x = 12
		Width.Width4:
			shape.extents.x = 16
			$CollisionShape2D.position.x = 16
			$StaticBody2D/CollisionShape2D.position.x = 16
		_:
			print("Illegal width provided.")

	# Shape
	$CollisionShape2D.shape = shape
	$StaticBody2D/CollisionShape2D.shape = shape
	
	width = _width
