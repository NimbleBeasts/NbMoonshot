extends "res://Src/Levels/BaseLevel.gd"


var decoupled = false
var bombPlaced = false


# Called when the node enters the scene tree for the first time.
func _ready():
	$LevelObjects/Objects/Trains/Train/LeftBlocker.position = Vector2(0, 8)
	$LevelObjects/Objects/Trains/Wagons.position = Vector2(0, 0)


func unlock():
	if not decoupled:
		$LevelObjects/Objects/Trains/Wagons/AnimationPlayer.play("decouple")

func hit():
	$Player.onGameOver()

func _on_AnimationPlayer_animation_finished(anim_name):
	if bombPlaced:
		$LevelObjects/ExtractionZone.manualLevelFinish()
	else:
		$Player.onGameOver()

# Called by AnimationPlayer
func playBombSound():
	if bombPlaced:
		$LevelObjects/Objects/Trains/Wagons/WagonTarget/BombArea/Bomb.play()


func _on_Area2D_area_entered(area):
	if area.is_in_group("Pickupable"):
		print("bomb armed")
		#TODO: do we emit a notification anywhere?!?
		$LevelObjects/Objects/Trains/Wagons/WagonTarget/BombArea/BombArm.play()
		bombPlaced = true

func _on_Area2D_area_exited(area):
	if area.is_in_group("Pickupable"):
		bombPlaced = false
		
