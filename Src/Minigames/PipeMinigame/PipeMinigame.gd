extends Minigame


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var pipe_part:PackedScene = load("res://Src/Minigames/PipeMinigame/PipePart.tscn")
var pipe_root
var water_line
#var plan1 = [2,0,1,3, 0,1,1,0, 1,1,1,1]

var plan1 = [2,0,1, 1,1,1, 0,1,1, 3,0,1]
var plan2 = [2,1,0, 1,0,1, 0,1,1, 3,0,1]
var plan3 = [2,0,1, 1,0,1, 1,0,1, 3,0,1]
var plan4 = [2,0,1, 1,1,0, 1,0,0, 3,0,1]
var plan5 = [2,1,0, 0,1,1, 0,1,1, 3,1,0]
var plan6 = [2,1,1, 1,0,1, 1,0,1, 3,1,1]

var plans = [
	[2,0,1, 1,1,1, 0,1,1, 3,0,1],
	[2,1,0, 1,0,1, 0,1,1, 3,0,1],
	[2,0,1, 1,0,1, 1,0,1, 3,0,1],
	[2,0,1, 1,1,0, 1,0,0, 3,0,1],
	[2,1,0, 0,1,1, 0,1,1, 3,1,0],
	[2,1,1, 1,0,1, 1,0,1, 3,1,1]
	]

var nextGroup
var waterDir = Vector2.DOWN
var speed = 1.0

var selector
var index = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	pipe_root = get_node("Pipes")
	water_line = get_node("WaterLine")
	selector = get_node("Selector")
	
	var plan = plans[ randi() % plans.size() ]
	
	for c in 4:
		for r in 3:
			var spwn : Sprite = pipe_part.instance()
			pipe_root.add_child(spwn)
			spwn.position = Vector2(c*64, r*64)
			spwn.set_type(plan.pop_front())
	
	water_line.position = pipe_root.get_child(0).global_position + Vector2.UP*31
	
	#start game
	water_line.add_point( Vector2.DOWN*1 + water_line.points[ water_line.points.size() -1 ] )

# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
func _physics_process(delta):
	
	if( water_line.points.size() > 1 ):
		

		
		speed = clamp( speed + delta * 10 , 5, 80 )
		
		water_line.points[ water_line.points.size() -1 ] += waterDir * delta * speed
		
		
		var m1 = get_node("Marker")
		var m2 = get_node("Marker2")
		#m.position = water_line.points[ water_line.points.size() -1 ]
		var point = water_line.points[ water_line.points.size() -1 ] + water_line.global_position
		var wlpoint = water_line.points[ water_line.points.size() -1 ]
		
		var space_state = get_world_2d().direct_space_state
		#var result = space_state.intersect_ray( water_line.points[ water_line.points.size() -1 ], water_line.points[ water_line.points.size() -1 ]+Vector2.ONE)
		#var result = space_state.intersect_point_on_canvas( water_line.points[ water_line.points.size() -1 ] )
		
		#var result = space_state.intersect_ray( point , point + Vector2.ONE)
		
		#start raycast bug fix i think
		if( water_line.points[0].distance_to( water_line.points[1]) < 20 ):
			return
		#-----------------------------
		
		
		
		var res = get_world_2d().direct_space_state.intersect_point_on_canvas( point,1 )#,1,[], 262144 )
		
		#print(point, "  ", pipe_root.get_child(index).global_position )
		#var res = get_world_2d().direct_space_state.intersect_point( point )#,1,[], 262144 )
		m2.global_position = point
		m1.global_position = point + Vector2.RIGHT*10
		
		var result = null
		
		if( res.size() > 0 ):
			print(res[0].collider.name, " of ", res[0].collider.get_parent().name)
			result = res[0]
			
		
		
		if result:
			#print( "hited, ", result.collider.name )
			if "PipeEnd" in result.collider.name:
				nextGroup = result.collider.get_parent().water_interact(result.collider.name)
				
			if "PipeWrong" in result.collider.name:
				set_physics_process(false)
				for p in pipe_root.get_children():
					p.interactable = false
				print("GAME OWER")
				set_result(Types.MinigameResults.Failed)
				close()
				
			if "PipeWin" in result.collider.name:
				set_physics_process(false)
				for p in pipe_root.get_children():
					p.interactable = false
				print("WON GAME")
				set_result(Types.MinigameResults.Succeeded)
				close()
				
		if nextGroup == null:
			return
		else:
			var pos = wlpoint + Vector2(0,-32)
			#m.position = pos
			pos = pos.round()
			#print( pos )
			#if( pos  == nextGroup[0].round() ):
			if pos.distance_to( nextGroup[0] ) < 2:
				water_line.add_point(nextGroup[0] + Vector2(0,32))
				waterDir = nextGroup[1]
				nextGroup = null

func _input(event):
	if event is InputEventMouse:
		selector.hide()
	else:
		moveByKeys(event)

func moveByKeys(event):
	
	if event.is_action_pressed("move_up"):#-3
		if not index in [0,3,6,9] : index = index - 1
		selector.show()
		
	if event.is_action_pressed("move_down"):#+3
		if not index in [2,5,8,11] : index = index + 1
		selector.show()
		
	if event.is_action_pressed("move_right"):#+1
		if index < 12: index = index + 3
		selector.show()
		
	if event.is_action_pressed("move_left"):#-1
		if index > 2: index = index - 3
		selector.show()
	
	index = clamp( index, 0, 11.1)
	selector.global_position = pipe_root.get_child(index).global_position
	pipe_root.get_child(index).get_node("TextureButton").grab_focus()
