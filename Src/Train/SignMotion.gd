extends Node2D

var scene = preload("res://Src/Train/SignPost.tscn")



export var speed = 0.4
export var amount = 3
var time: float

var positionStart: Vector2
var positionStop: Vector2

func _ready():
	positionStart = get_node("PositionStart").position
	positionStop = get_node("PositionStop").position
	
	# Scrollspeed of parallax bg is 640px per second (UV*time*scaler)
	# Running on 0.4 level speed => 256px per second
	var distance: float = float(positionStart.distance_to(positionStop))
	time = distance / (640.0 * speed)
	
	$Timer.wait_time = time / amount
	$Timer.start()


func collision(body):
	if body.is_in_group("Player"):
		get_parent().get_parent().get_parent().hit()


func setupSign():
	# Instance Sign
	var node = scene.instance()
	node.position = positionStart
	self.add_child(node)
	# Connect Collider
	var area: Area2D = node.get_node("Area2D")
	area.connect("body_entered", self, "collision")
	# Setup Tween
	var tween: Tween = node.get_node("Tween")
	tween.interpolate_property(node, "position", positionStart, positionStop, time, Tween.TRANS_LINEAR)
	tween.start()
	tween.repeat = true
	yield(get_tree().create_timer(time/3*2), "timeout")


func _on_Timer_timeout():
	setupSign()
	amount -= 1
	if amount > 0:
		$Timer.start()
