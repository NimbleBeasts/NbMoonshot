tool
extends Node2D

enum CabinetType {Blue = 0, Grey = 1, Brown = 2} 

export(CabinetType) var type = CabinetType.Blue
export(bool) var hasBounty = false
export(int) var bounty = 20

var isLooted = false
var playerInRange = false


func _ready():
	$Sprite.frame = type
	
	if not hasBounty:
		self.remove_child($Area2D)

func _process(delta):
	if playerInRange:
		if Input.is_action_just_pressed("open_minigame"):
			if hasBounty and not isLooted:
				# Add money popup anim
				# Emit Hud money update
				isLooted = true
				$AnimationPlayer.play("loot")
				print("looted")
				pass
			else:
				print("no loot")


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		playerInRange = true


func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		playerInRange = false
