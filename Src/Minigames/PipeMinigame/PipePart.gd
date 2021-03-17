extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var interactable = true;
onready var end1 : KinematicBody2D = get_node("PipeEnd1")
onready var end2 = get_node("PipeEnd2")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_type(what:int):
	frame = what
	
	if( what == 0 ): #I shape
		get_node("PipeWrong3").queue_free()
		rotation_degrees = [0,90,180,270][randi()%4]
	
	if( what == 1 ): #L shape
		end2.position = Vector2(22,0)
		get_node("PipeWrong2").queue_free()
		rotation_degrees = [0,90,180,270][randi()%4]
	
	
	
	if what == 2 or what == 3:
		frame = 0
		if what == 3:
			get_node("InOutMark").frame = 3
		get_node("InOutMark").show()
		interactable = false
		get_node("PipeWrong3").queue_free()
		
		if( what == 3 ): #OUT
			get_node("PipeEnd2").queue_free()
			var win = get_node("PipeEnd1")
			win.name = "PipeWin"
			win.position = Vector2(0,-36)
		
		if( what == 2): #IN
			get_node("PipeEnd1").queue_free()
			get_node("PipeEnd2").queue_free()

func water_interact(var whatEnd):
	if( interactable == false ):
		return null
	
	interactable = false
	var re = Vector2.ZERO
	
	if "1" in whatEnd:
		re = end2.global_position
	else:
		re = end1.global_position
	
	re = global_position - re
	re = -re.normalized()
	if( abs(re.x) > abs(re.y) ):
		re = Vector2(re.x, 0)
	else:
		re = Vector2(0, re.y)
	
	
	end1.queue_free()
	end2.queue_free()
	return [ position, re ]

func _on_TextureButton_button_up():
	interact()

func interact():
	if interactable:
		rotation_degrees += 90
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
