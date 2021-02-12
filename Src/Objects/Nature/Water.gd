tool
extends Sprite

enum FlowDirectionType {Left = 0, Right = 1}

const directions = [1.0, -1.0]

export (FlowDirectionType) var flow = FlowDirectionType.Right

func _ready():
	_on_Water_item_rect_changed()

func _on_Water_item_rect_changed():
	self.material.set('shader_param/scale_x', float(self.scale.x))
	self.material.set('shader_param/direction', directions[flow])
	
