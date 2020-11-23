tool
extends Door

enum DoorLockType {open, lockedLevel1, lockedLevel2, locked}
export(DoorLockType) var lockLevel = DoorLockType.open
var open: bool = false

export var door_name : String = ""

func _ready():
	animPlayer.connect("animation_finished", self, "onAnimationFinished")
	#lockLevel = DoorLockType.locked
	$Sprite.frame = 0
	
	if door_name != "":
		Events.connect("door_change_status", self, "_on_door_change_status")
	
	# if lockLevel == DoorLockType.open:
	# 	$Sprite.frame = 2
	# else:
	# 	$Sprite.frame = 0
	

# overriden
func interact() -> void:
	if lockLevel == DoorLockType.lockedLevel1:
		$LockpickSmallMinigameSpawner.run_minigame(door_name, 1, true)
		return
	if lockLevel == DoorLockType.lockedLevel2:
		$LockpickSmallMinigameSpawner.run_minigame(door_name, 2, true)
		return
	
	
	# teleports to connected door
	if connected_door and not animPlayer.is_playing():
		Events.emit_signal("block_player_movement")
		Events.emit_signal("player_enter_door")
		print("entered door")
		animPlayer.play("open")
		Events.emit_signal("play_sound", "door_wooden_open")
		open = true
	else:
		print("Trying to teleport but no connected door for " + name)
		

func onAnimationFinished(animName: String) -> void:
	if open:
		player.global_position = connected_door.get_node("PlayerTeleportPosition").global_position
		connected_door.animPlayer.play_backwards("open")
		Events.emit_signal("play_sound", "door_wooden_close")
		Events.emit_signal("unblock_player_movement")
		Events.emit_signal("player_exit_door")
		print("exit door")
		open = false
		
func _on_door_change_status(_door_name, _lock_type, _run_anim):
	if door_name == _door_name:
		lockLevel = _lock_type
		if _run_anim:
			interact()
