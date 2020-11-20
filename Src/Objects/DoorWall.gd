
tool
extends Node2D

var minigame_finished: bool = false
var playerInArea = false
var doorIsOpen = false
var playerNode = null

enum DoorLockType {open, lockedLevel1, lockedLevel2, locked}
enum DoorType {wooden, metal}

export(DoorLockType) var lockLevel = DoorLockType.open
export(DoorType) var doorType = DoorType.wooden
export var door_name = "" 
export var save_state = false

export (Array)  var sig_to_trig

func _ready():
	if doorType == DoorType.metal:
		$Sprite.texture = preload("res://Assets/Objects/DoorWallMetal.png")
	else:
		$Sprite.texture = preload("res://Assets/Objects/DoorWall.png")
	set_process(false)
	
	$Sprite.frame = 0
	
	
	if door_name != "":
		Events.connect("door_change_status", self, "_on_door_change_status")
	
		#load state form save if it exists
		if Global.gameState.has(door_name):
			print("Has door name")
			lockLevel = Global.gameState[door_name]
		
func open():
	lockLevel = DoorLockType.open

func _process(_delta):
	if playerInArea:
		if Input.is_action_just_pressed("interact"):
			interact(true)
			
func interact(run_sub):
	print("lock lvl is:",lockLevel)
	
	#pick difent minigames depening on type if locked
	if doorType == DoorType.wooden:
		if lockLevel == DoorLockType.lockedLevel1:
			$LockpickSmallMinigameSpawner.run_minigame(door_name, 1, true)
			return
		if lockLevel == DoorLockType.lockedLevel2:
			$LockpickSmallMinigameSpawner.run_minigame(door_name, 2, true)
			return
	if doorType == DoorType.metal:
		if lockLevel == DoorLockType.lockedLevel1:
			$LightMinigameSpawner.run_minigame(door_name,1,true)
			return
	
	#if its open just play anims
	if lockLevel == DoorLockType.open:
		if not doorIsOpen:
			
			#check if player close then open to oposit direction of player
			if playerNode != null:
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
		set_process(true)


func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		playerNode = null
		playerInArea = false
		set_process(false)

func _on_door_change_status(_door_name, _lock_type, _run_anim):
	if door_name == _door_name:
		lockLevel = _lock_type
		if save_state:
			Global.gameState[door_name] = _lock_type
		if _run_anim:
			interact(false)
		
