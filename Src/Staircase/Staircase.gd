tool
extends Door

enum DoorLockType {open, lockedLevel1, lockedLevel2, locked}
export(DoorLockType) var lockLevel = DoorLockType.open


func _ready():
	if lockLevel == DoorLockType.open:
		$Sprite.frame = 2
	else:
		$Sprite.frame = 0
