tool
extends Sprite

enum TreeType {Deciduous = 0, Needle = 1}
enum SeasonType {Normal, Autumn}
enum VariantType {Var1, Var2}

export (TreeType) var tree = TreeType.Deciduous
export (SeasonType) var season = SeasonType.Normal
export (VariantType) var variant = VariantType.Var1

const treeSprites = [
	preload("res://Assets/Objects/Nature/Tree_Deciduous.png"),
	preload("res://Assets/Objects/Nature/Tree_Needle.png")
]


func _ready():
	var tempVar = variant
	
	# Set tree type
	if tree == TreeType.Deciduous:
		self.texture = treeSprites[0]
		self.hframes = 4
		if season == SeasonType.Autumn:
			tempVar += 2
	else:
		self.texture = treeSprites[1]
		self.hframes = 2

	# Set frame
	self.frame = tempVar
	
	var rand = randf() 
	self.material.set('shader_param/start_offset', rand)
	
	

