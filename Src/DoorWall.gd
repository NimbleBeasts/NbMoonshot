tool
extends Node2D
class_name DoorWall

var playerInArea = false
var doorIsOpen = false
var playerNode = null
var startingLockLevel: int


enum DoorType {wooden, metal, metalSwing, glass}

export(Types.DoorLockType) var lockLevel = Types.DoorLockType.open
export(DoorType) var doorType = DoorType.wooden setget update_texture
export var save_state = false
#warning-ignore:unused_class_variable
export var hint: String
export var keyPath: NodePath
export var doorLockStateLocked: bool = true

export (Array)  var sig_to_trig
onready var key

func _ready():
	set_process_unhandled_input(false)
	startingLockLevel = lockLevel

	# Requires a key? Show key sign
	if lockLevel == Types.DoorLockType.keyLocked:
		key = get_node(keyPath)
		$KeySign.show()
		$KeySign.frame = key.keyColor

	# Reset Anim Frame
	$Sprite.frame = 0
	
	# Load state form save if it exists
	if Global.gameState.has("TutorialDoor") and self.name == "TutorialDoor":
		lockLevel = Global.gameState["TutorialDoor"]

	Events.connect("minigame_door_change_status", self, "_on_minigame_door_change_status")


func update_texture(new_door_type) -> void:
	doorType = new_door_type
	if doorType == DoorType.metal:
		$Sprite.texture = preload("res://Assets/Doors/DoorWallMetal.png")
	elif doorType == DoorType.metalSwing:
		$Sprite.texture = preload("res://Assets/Doors/DoorWallMetal2.png")
	elif doorType == DoorType.glass:
		$Sprite.texture = preload("res://Assets/Doors/DoorWallGlass.png")
	else:
		$Sprite.texture = preload("res://Assets/Doors/DoorWall.png")


func unlock():
	doorLockStateLocked = !doorLockStateLocked
	# print("unlock")
	# print(doorLockStateLocked)


func open():
	#print("door open")
	lockLevel = Types.DoorLockType.open


func resetState() -> void:
	lockLevel = startingLockLevel


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if playerNode.canInteract:
			interact(true, playerNode.global_position)
			get_tree().set_input_as_handled()
			

func interact(run_sub, openerPos: Vector2):
	if playerNode != null:
		if openerPos == playerNode.global_position and playerNode.state == Types.PlayerStates.DraggingGuard:
			return

	# print("active node:" + str(self))
	# shows a game hint if this door is locked

	match lockLevel:
		Types.DoorLockType.keyLocked:
			if key.isPickedUp:
				open()
				$DoorSounds/KeyUse.play()
			else:
				Events.emit_signal("hud_game_hint", tr("KEY_DOOR_REQUIRED") % tr(key.stringName))
				return
		Types.DoorLockType.locked:
			$DoorSounds/Locked.play()
			Events.emit_signal("hud_game_hint", tr(hint))
			return
		Types.DoorLockType.lockedLevel1:

			if doorType == DoorType.wooden:
				$LockpickSmallMinigameSpawner.run_minigame(self, 1, true)
			else:
				$SimonSays.run_minigame(self)
			return
		Types.DoorLockType.lockedLevel2:

			if doorType == DoorType.wooden:
				$LockpickSmallMinigameSpawner.run_minigame(self, 2, true)
			else:
				$SimonSays.run_minigame(self)
				#$LightMinigameSpawner.run_minigame(self, 1, true)
			return
		Types.DoorLockType.buttonLocked:
			if doorLockStateLocked:
				$DoorSounds/Locked.play()
			else:
				#print("opened")
				playDoorAnimation(openerPos)
		_:
			# Open the door
			playDoorAnimation(openerPos)

	#try to run sub events if needed and they exist
	if run_sub:
		try_sub_emit()


func playDoorAnimation(openerPos):
	if not doorIsOpen:
		# Open Animation
		if openerPos.x < self.global_position.x:
			# Left Side
			$Sprite.scale.x = 1
		else:
			# Right Side
			$Sprite.scale.x = -1
		$AnimationPlayer.play("open_door")
		doorIsOpen = true
		# playing sound
		if doorType == DoorType.wooden:
			$DoorSounds/WoodenOpen.play()
		elif doorType == DoorType.glass:
			$DoorSounds/WoodenOpen.play()
		else:
			$DoorSounds/MetalOpen.play()
	else:
		# Close Animation
		$AnimationPlayer.play_backwards("open_door")
		doorIsOpen = false
		if doorType == DoorType.wooden:
			$DoorSounds/WoodenClose.play()
		elif doorType == DoorType.glass:
			$DoorSounds/WoodenClose.play()
		else:
			$DoorSounds/MetalClose.play()


func try_sub_emit():
	for sig in sig_to_trig:
		if sig.size() > 0:
			if typeof(sig[0]) != TYPE_STRING or sig[0] == "":
				print("WARNING bad subemiter on ", name)
				return
			var emitRef = funcref(Events, "emit_signal")
			emitRef.call_funcv( sig )


func _on_AnimationPlayer_animation_finished(_anim_name):
	if not doorIsOpen:
		# Door is now open
		$StaticBody2D/CollisionShape2D.set_disabled(false)
	else:
		# Door is now closed
		$StaticBody2D/CollisionShape2D.set_disabled(true)


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		playerNode = body
		playerInArea = true
#		set_process(true)
		set_process_unhandled_input(true)


func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		playerNode = null
		playerInArea = false
#		set_process(false)
		set_process_unhandled_input(false)


func _on_minigame_door_change_status(instance, _lock_type, _run_anim):
	# print("signal rec")
	# print(instance)
	# print(self)
	if instance == self:
		#print("match")
		lockLevel = _lock_type
		if save_state:
			Global.gameState["TutorialDoor"] = _lock_type
		if _run_anim:
			interact(false, Global.player.global_position)
		
