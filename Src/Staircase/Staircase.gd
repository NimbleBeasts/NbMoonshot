tool
extends Door


enum DoorType {wooden, metalSwing}
enum DoorDirectionType {none = 0, up = 1, down = 2}

export(Types.DoorLockType) var lockLevel = Types.DoorLockType.open
export(DoorType) var doorType = DoorType.wooden
export(DoorDirectionType) var directionIndication = DoorDirectionType.none setget changeDirectionIndication
var open: bool = false


func _ready():
	#warning-ignore:return_value_discarded
	animPlayer.connect("animation_finished", self, "onAnimationFinished")
	#lockLevel = DoorLockType.locked
	$Sprite.frame = 0
	
	Events.connect("minigame_door_change_status", self, "_on_minigame_door_change_status")
	
	if doorType == DoorType.metalSwing:
		$Sprite.texture = preload("res://Assets/Doors/StaircaseMetal.png")
	else:
		$Sprite.texture = preload("res://Assets/Doors/Staircase.png")
	

func changeDirectionIndication(val):
	$Direction.frame = val
	directionIndication = val
	


# overriden
func interact() -> void:
	match lockLevel:
		Types.DoorLockType.lockedLevel1:
			$LockpickSmallMinigameSpawner.run_minigame(self, 1, true)
			return
		Types.DoorLockType.lockedLevel2:
			$LockpickSmallMinigameSpawner.run_minigame(self, 2, true)
			return
		Types.DoorLockType.locked:
			$DoorSounds/Locked.play()
			return
		_:
			pass

	# teleports to connected door
	if connected_door and not animPlayer.is_playing():
		Events.emit_signal("player_block_input")
		animPlayer.play("open")
		if doorType == DoorType.wooden:
			$DoorSounds/WoodenOpen.play()
		else:
			$DoorSounds/MetalOpen.play()
		open = true
	else:
		print("Trying to teleport but no connected door for " + name)
		

func onAnimationFinished(_animName: String) -> void:
	if open:
		player.global_position = connected_door.get_node("PlayerTeleportPosition").global_position
		connected_door.animPlayer.play_backwards("open")
		if doorType == DoorType.wooden:
			$DoorSounds/WoodenClose.play()
		else:
			$DoorSounds/MetalClose.play()
		Events.emit_signal("player_unblock_input")
		Events.emit_signal("player_unblock_movement")
		open = false
		
func _on_minigame_door_change_status(targetInstance, _lock_type, _run_anim):
	if targetInstance == self:
		lockLevel = _lock_type
		if _run_anim:
			interact()
