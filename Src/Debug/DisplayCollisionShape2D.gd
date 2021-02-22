extends CollisionShape2D

export(Color, RGBA) var col = Color(1,0.1,1,1)
export(int) var layer = 500

var box = [Vector2(), Vector2(), Vector2(), Vector2()]

# Called when the node enters the scene tree for the first time.
func _ready():
	self.z_index = layer
	box[0] = Vector2(-self.shape.extents.x, self.shape.extents.y)
	box[1] = Vector2(self.shape.extents.x, self.shape.extents.y)
	box[2] = Vector2(self.shape.extents.x, -self.shape.extents.y)
	box[3] = Vector2(-self.shape.extents.x, -self.shape.extents.y)



func _draw():
	draw_line(box[0], box[1], col)
	draw_line(box[1], box[2], col)
	draw_line(box[2], box[3], col)
	draw_line(box[3], box[0], col)
	
