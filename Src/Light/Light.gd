extends Node2D

var debugPoints = []

# hmmmmmm this is shit :<

func _draw():
	for point in debugPoints:
		draw_circle(point, 6, Color(255,150,0))

func raycastToPlayer(targetPos):
	targetPos -= Vector2(0, 16)
	debugPoints = [Vector2(0, 0), targetPos]
	
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(Vector2(0, 0), targetPos)
	
	if result:
		debugPoints.append(result.position)
	print(result)
	print(debugPoints)
	update()
	


func _on_FullLight_body_entered(body):
	if body.is_in_group("Player"):
		raycastToPlayer(body.position - global_position)

func _on_BarelyVisible_body_entered(body):
	if body.is_in_group("Player"):
		raycastToPlayer(body.position - global_position)
