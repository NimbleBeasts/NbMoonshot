extends Node2D

var playerInArea = false
var doorIsOpen = false
var playerNode = null

enum DoorType {open, lockedLevel1, lockedLevel2}

export(DoorType) var lockLevel = DoorType.open


func _ready() -> void:
	$Area2D.connect("minigame_succeeded", self, "_on_minigame_succeeded")
	set_process(false)

	
func _process(delta):
	if playerInArea:
		if Input.is_action_just_pressed("interact"):
			if not doorIsOpen:
				# Open Animation
				if playerNode.position.x < self.global_position.x:
					# Left Side
					$Sprite.scale.x = 1
				else:
					# Right Side
					$Sprite.scale.x = -1
				$AnimationPlayer.play("open_door")
			else:
				# Close Animation
				$AnimationPlayer.play_backwards("open_door")



func _on_minigame_succeeded() -> void:
	set_process(true)


func _on_AnimationPlayer_animation_finished(anim_name):
	if not doorIsOpen:
		# Door is now open
		doorIsOpen = true
		$StaticBody2D/CollisionShape2D.set_disabled(true)
	else:
		# Door is now closed
		doorIsOpen = false
		$StaticBody2D/CollisionShape2D.set_disabled(false)


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		playerNode = body
		playerInArea = true


func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		playerNode = null
		playerInArea = false

