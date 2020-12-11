extends Node2D

export(Array, NodePath) var deactivateAble = []


# Called when the node enters the scene tree for the first time.
func _ready():
	#warning-ignore:return_value_discarded
	$WireCutSpawner.connect("minigame_succeeded", self, "wireCutSuccess")


func wireCutSuccess():
	$AnimationPlayer.play("cracked")
	for nodePath in deactivateAble:
		var node = get_node(nodePath)
		
		if node.has_method("deactivate"):
			node.deactivate()
		else:
			print("Error: " + str(nodePath) + " has no deactivate()")
