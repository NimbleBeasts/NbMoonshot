extends Node

export var dr_monkey : NodePath
export var monkey : NodePath
export var elit_guard : NodePath
export var sprinkler_root : NodePath

var pipefixed = false
var guardsqashed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("custom_level_event", self,  "_custom_level_event")
	pass # Replace with function body.

func _custom_level_event(whatLevel, whatEvent):
	if whatLevel != "Level3":
		return
		
	if whatEvent == "PipeFixed" and not pipefixed:
		PipeFixScenario()
		

func PipeFixScenario():
	print("Fixed pipes")
	pipefixed = true;
	
	#sprinklers on
	var spr : Node2D = get_node(sprinkler_root)
	for sp in spr.get_children():
		sp.show()
	
	#door1
	yield(get_tree().create_timer(1.0), "timeout")
	Events.emit_signal("play_sound", "door_metal_open")
	yield(get_tree().create_timer(0.5), "timeout")
	Events.emit_signal("play_sound", "door_metal_close")
	
	#door2
	yield(get_tree().create_timer(1.0), "timeout")
	Events.emit_signal("play_sound", "door_metal_open")
	yield(get_tree().create_timer(0.5), "timeout")
	Events.emit_signal("play_sound", "door_metal_close")
	
	#door3
	yield(get_tree().create_timer(1.0), "timeout")
	Events.emit_signal("play_sound", "door_metal_open")
	yield(get_tree().create_timer(0.5), "timeout")
	Events.emit_signal("play_sound", "door_metal_close")
	
	get_node(dr_monkey).global_position = Vector2(300,256)
	get_node(monkey).global_position = Vector2(-90, 239)
	get_node(monkey).scale.x = -1


func _on_BarrelFallDetector_area_entered(area):
	if "BarrelOil" in area.name and not guardsqashed:
		guardsqashed = true
		print("Guard dead")
		
		#destory guard and barrel
		get_node(elit_guard).queue_free()
		
		#show Aaa and put pic of squashed guard
		yield(get_tree().create_timer(1.0), "timeout")
		$Aaaa.show()
		yield(get_tree().create_timer(2.0), "timeout")
		$Aaaa.hide()
		area.queue_free()
		$BarrelRedSquashGuard.show()
		
		SteamWorks.setAchievement("STEAM_ACH_6") #Headache
