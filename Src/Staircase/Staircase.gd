tool
extends Door

enum DoorLockType {open, lockedLevel1, lockedLevel2, locked}
export(DoorLockType) var lockLevel = DoorLockType.open
var open: bool = false

func _ready():
	animPlayer.connect("animation_finished", self, "onAnimationFinished")
	lockLevel = DoorLockType.locked
	$Sprite.frame = 0
	# if lockLevel == DoorLockType.open:
	# 	$Sprite.frame = 2
	# else:
	# 	$Sprite.frame = 0
	

# overriden
func interact() -> void:
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
		

