tool
extends Node2D
class_name DoorWall

var minigame_finished: bool = false
var playerInArea = false
var doorIsOpen = false
var playerNode = null
var startingLockLevel: int

enum DoorLockType {open, lockedLevel1, lockedLevel2, locked, buttonLocked, keyLocked}
enum DoorType {wooden, metal, metalSwing} 

export(DoorLockType) var lockLevel = DoorLockType.open
export(DoorType) var doorType = DoorType.wooden setget update_texture
export var save_state = false
export var showHintIfLocked: bool = false
export var hint: String
export var keyPath: NodePath

export (Array)  var sig_to_trig

onready var key


func _ready():
	set_process_unhandled_input(false)
	startingLockLevel = lockLevel
	if lockLevel == DoorLockType.keyLocked:
		key = get_node(keyPath)
		$KeySign.show()
		$KeySign.frame = key.keyColor
		
#	update_texture(doorType)

	$Sprite.frame = 0
	
	Events.connect("minigame_door_change_status", self, "_on_minigame_door_change_status")

	#load state form save if it exists
	if Global.gameState.has("TutorialDoor"):
		lockLevel = Global.gameState["TutorialDoor"]

func update_texture(new_door_type) -> void:
	doorType = new_door_type
	if doorType == DoorType.metal:
		$Sprite.texture = preload("res://Assets/Doors/DoorWallMetal.png")
	elif doorType == DoorType.metalSwing:
		$Sprite.texture = preload("res://Assets/Doors/DoorWallMetal2.png")
	else:
		$Sprite.texture = preload("res://Assets/Doors/DoorWall.png")


func open():
	lockLevel = DoorLockType.open


func resetState() -> void:
	lockLevel = startingLockLevel


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if playerNode.state != Types.PlayerStates.DraggingGuard:
			interact(true, playerNode.global_position)
			get_tree().set_input_as_handled()
			

func interact(run_sub, openerPos: Vector2):
	if playerNode != null:
		if openerPos == playerNode.global_position and playerNode.state == Types.PlayerStates.DraggingGuard:
			return
		
	if lockLevel == DoorLockType.keyLocked:
		if key.isPickedUp:
			open()
			Events.emit_signal("play_sound", "key_use")
		else:
			Events.emit_signal("hud_game_hint", "You need a %s key to open this door" % key.stringName)
	print("active node:" + str(self))
	# shows a game hint if this door is locked
	if lockLevel == DoorLockType.locked:
		Events.emit_signal("hud_game_hint", hint)
	#pick difent minigames depening on type if locked
	if doorType == DoorType.wooden:
		if lockLevel == DoorLockType.lockedLevel1:
			$LockpickSmallMinigameSpawner.run_minigame(self, 1, true)
			return
		if lockLevel == DoorLockType.lockedLevel2:
			$LockpickSmallMinigameSpawner.run_minigame(self, 2, true)
			return
	if doorType == DoorType.metal:
		if lockLevel == DoorLockType.lockedLevel1:
			$SimonSays.run_minigame(self)
			return
		if lockLevel == DoorLockType.lockedLevel2:
			$LightMinigameSpawner.run_minigame(self,1,true)
			return
	

	
	#if its open just play anims
	if lockLevel == DoorLockType.open:
		if not doorIsOpen:
			
			# Open Animation
			if openerPos.x < self.global_position.x:
				# Left Side
				$Sprite.scale.x = 1
			else:
				# Right Side
				$Sprite.scale.x = -1
			$AnimationPlayer.play("open_door")
			# playing sound
			if doorType == DoorType.wooden:
				Events.emit_signal("play_sound", "door_wooden_open")
			else:
				Events.emit_signal("play_sound", "door_metal_open")
		else:
			# Close Animation
			$AnimationPlayer.play_backwards("open_door")
			if doorType == DoorType.wooden:
				Events.emit_signal("play_sound", "door_wooden_close")
			else:
				Events.emit_signal("play_sound", "door_metal_close")

	#try to run sub events if needed and they exist
	if run_sub:
		try_sub_emit()
			
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
#		set_process(true)
		set_process_unhandled_input(true)


func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		playerNode = null
		playerInArea = false
#		set_process(false)
		set_process_unhandled_input(false)


func _on_minigame_door_change_status(instance, _lock_type, _run_anim):
	print("signal rec")
	print(instance)
	print(self)
	if instance == self:
		print("match")
		lockLevel = _lock_type
		if save_state:
			#TODO workaround here
			Global.gameState["TutorialDoor"] = _lock_type
		if _run_anim:
			interact(false, Global.player.global_position)
		
